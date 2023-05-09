# Automated Network Validation

This repository provides an automated process to checking the validity of network configuration files generated during lab sessions.

To use this repository, each student group need to:

1. Select one student to carry out the remaining tasks
2. Clone the main branch of this repository
3. Create a branch named after their group
4. Copy network device configuration to the branch
5. Commit and push the branch
6. Check if their configuration files have passed the tests

Instructors and students need a GitHub account to be able to push lab configuration and view results. To eliminate redundant work, only one student from each lab group is needed to follow the steps below.

Instructors will also be able to view the results and advise students on how to fix any errors.

## Instructions for Students:

Follow these instructions after completing all lab configuration steps:

1. Clone the main branch of this repository in the lab's VM home directory:
   ```
   $ cd
   $ git clone --branch main https://github.com/martimy/Network_Design
   ```
2. Create a branch named after your lab and group numbers (use the format labX_gYY, where X is the lab number and YY is your group number) and checkout the branch:
   ```
   $ cd Network_Design
   $ git checkout -b lab1_g99
   ```
3. Copy network device configuration using Ansible:
   ```
   $ export ANSIBLE_HOST_KEY_CHECKING=False
   $ ansible-playbook -i inventory.txt play_backup.yml
   ```
   If the above process was successful (all routers report ok=1), then you will find a folder 'lab/configs' created in the repository. If the process failed, then it is likely that the SSH configuration on the network devices is not completed and you must follow the instructions in the lab assignment documents to configure SSH.
4. Commit the changes and push the branch:  
   *Note: you will need a Github account to complete this step. You also need to be added as a collaborator to the repository by the course instructor. When asked for username/password, enter your GitHub username and your token (instead of password). You can obtain an access token by following the instructions in this [link](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).*

   ```
   $ git add lab
   $ git status
    On branch lab1_g99
    Changes to be committed:
      (use "git reset HEAD <file>..." to unstage)

            new file:   lab/configs/R11.cfg
            new file:   lab/configs/R12.cfg
            new file:   lab/configs/R21.cfg
            new file:   lab/configs/R22.cfg
            new file:   lab/configs/R23.cfg
   $ git commit -m "add config files for group g99"
   $ git push --set-upstream origin lab1_g99
   ```
5. Check if your configuration files have passed the checks:
   - Go the github [repository](https://github.com/martimy/Network_Design)
   - click on 'barnches'   

   ![](img/branches.png)

   - Verify that you have a green checkmark in front of your branch. You can click on the checkmark to find details.

   ![](img/checks.png)


## Validation Tests

There are two categories of validation tests performed on the lab configuration:

### Parsing tests

Parsing tests are performed using simple parsing of configuration files to confirm the presence of specific lines of configuration. The tests are performed on all labs and they include:

- SNMP configuration check: Confirms the presence of SNMP community strings, location, and contact lines.
- SysLog configuration check: Confirms the presence of SysLog server line.
- Clock configuration check: Confirms the present of time zone settings.

The parsing test fail if any of these individual tests fail.


### Configuration tests

Batfish is a network configuration analysis tool that guarantees validity and correctness of a network's configuration by building a model of the network's behavior based on device configurations.

Batfish is used to perform simple tests on lab configuration files. These tests differ depending on the lab assignment.

**Labs 1 to 4 tests:**

- Number of Routers: Check of there are five configuration files and each file represents a unique router (no duplicates)
- Valid Configuration: Ensures that Batfish is able to recognize the vendor's configuration files.   
- Clean Parsing: Checks if there are certain configuration lines that Batfish cannot understand or ignores.
- Host Properties: Tests if the router's name, the domain name and NTP servers are configured as expected.
- Undefined References: Tests if there are structures (such as ACL) that are used in the configuration but not defined.
- Shut Interfaces: Tests if all unused interfaces are shutdown.

Labs 1-4 configuring test fails if any of the above tests fail except the configuration and parsing tests. The test continues even if some configuration lines are not understood by Batfish.

**Lab 5 tests:**

Lab 5 checks include all previous checks and three more:

- Duplicate Router IDs: Checks there are no duplicate BGP router IDs.
- BGP Compatibility: Checks that there are no incompatible BGP sessions present in the configuration.
- BGP Unestablished: Checks if there BGP sessions that are compatible but not established.

Lab 5 configuration test fails if any of the above tests fail.


## Validation Process

This network validation process applies some CI/CD principles to check device configuration against some common configuration errors. The pipeline includes the following components:

![Pipeline](img/pipeline.png)

- [Ansible](https://www.ansible.com/) — Network automation tool (based on Python):  
  Ansible is used to automate the configuration of network devices as well at retrieve the configuration files in preparation for the configuration check.
- [Batfish](https://www.batfish.org/) — Network configuration analysis tool (based in Python):  
  Batfish performs vendor-independent validation of network configuration by answering several questions and comparing answers with expected results.   
- [Docker](https://www.docker.com/) — Platform for building, deploying, and managing containerized applications:  
  Docker runs several containers in the pipeline, including: Drone Server, Drone Runner, Batfish, and martimy/netauto.
- [Drone](https://www.drone.io/) — Continuous integration platform:  
  A Drone server manages the pipelines while one or more Drone runners poll the server for workloads to execute. The pipeline execution is triggered when a network configuration is pushed to the GitHub repository.
- [Git](https://git-scm.com/) — Revision control system:  
  Git tracks network configuration changes and pulls/pushes the configuration to a GitHub repository.
- [GitHub](https://github.com/) — Cloud-based Git repository:  
  Hosts all test scripts, Ansible scripts, and Drone configuration file. GitHub is also used to push network configuration files to trigger the checking pipeline.
- [martimy/netauto](https://hub.docker.com/r/martimy/netauto) — Docker image:  
  This is Python container that includes all modules needed to run the test scripts.
- [Python](https://www.python.org/) — Programming language for network applications:  
  All test software is written in Python, including scripts that run tests that are not available in Batfish.


## Software Installation

In order to run the network validation process, you need to install the software components on a server that is reachable form the GitHub repository. This section will guide you through the steps of installing Docker, Drone server and runner, and Batfish on a Ubuntu Linux server. It also provides instructions on how to configure the CI/CD pipeline and activate the repository for testing.

### Server installation

Docker, Drone server and runner(s) need to be installed on a publicly accessible server (hosted locally or in the Cloud). The installation steps are as follows (for Ubuntu Linux):


1. Installing Docker

    You can install Docker using the apt repository following these [instructions](https://docs.docker.com/engine/install/ubuntu/). For testing purposes, you can use the convenience-script [method](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script).


2. Creating GitHub OAuth Application

    Login to GitHub and go to (Settings -> Developer Settings -> OAuth Apps) From there click on the "New OAuth App" and add Drone information to OAuth Apps, including the server's URL. For example:

    - Homepage URL: http://my.server.com
    - Authorization callback URL: http://my.server.com/login

    Click on "Register application" and generate client secert. Record Client ID and Client Secret.


3. Generate a shared secret

    On the server, generate a shared secret between the Drone server and runners:


    ```
    $ openssl rand -hex 16
    ```

4. Install Drone

    Install Drone Server, and Drone Runner:

    ```
    $ docker pull drone/drone:2
    $ docker pull drone/drone-runner-docker:1
    ```


    At the Drone server host, edit the start_drone.sh script (in this repository) to include the following information: 

    - Client ID and Secret (from step 2) 
    - Runner secret (from step 3) 
    - Host IP address 
    - Admin username (optional)

    Also, edit the start_runner.sh script to include: 

    - Runner secret 
    - Host IP address


6. Start Drone and Runner

    Execute the script start_drone.sh and start_runner.sh

    ```
    $ ./start_drone
    $ ./start_runner
    ```  

7. Activate a Repository

    Direct your web browser to the server IP address. Log into the Drone server and activate the required repository (this one, for example).


8. Edit Settings (optional)

    In the repository Settings, add any secrets needed in your test scripts (e.g. Batfish server location)


9. Install Batfish

    Batfish is required to perform configuration tests. It can be installed on the same server as Drone or on another server accessible from the Drone Server.

    ```
    $ docker pull batfish/allinone
    $ docker run --name batfish -v batfish-data:/data -p 8888:8888 -p 9997:9997 -p 9996:9996 batfish/allinone
    ```

### Pipeline installation and configuration

This part requires the installation for Batfish's Docker image and configuring the CI/CD pipeline.

\<to be completed\>

**The .drone.yml file description:**

The .drone.yml file defines a pipeline that will run a series of checks on different labs based on their branch name.

Here is a breakdown of the different components of the file:

- `kind: pipeline`: Specifies that this is a pipeline definition.
- `type: docker`: Specifies the pipeline type as Docker.
- `name: Design Labs Configuration Check`: Assigns a name to the pipeline.
- `steps`: Specifies the individual steps of the pipeline, which are the tasks that will be executed in sequence.
- `name`: Assigns a name to the first step, which is `Lab Parser Check`.
- `image`: Specifies the Docker image that will be used for this step. In this case, it is `martimy/netauto:0.2`.
- `commands`: Specifies the command that will be executed in the Docker container. In this case, it is `python parser_check.py`.
- `when`: Specifies the conditions under which this step should be executed. In this case, it will only run when the branch name matches the regular expression `lab?_*`.
- The second and third steps (`Lab 1-4 Batfish Analysis` and `Lab 5 Batfish Analysis`) are similar to the first step, except that they run different Python scripts and are triggered by different branch names.
- `trigger`: Specifies the conditions under which the pipeline should be triggered. In this case, it will be triggered when the branch name matches the regular expression `lab?_*`.


## Acknowledgments

The development of this pipeline follows the examples and the tutorials included in:

[1] JulioPDX. "Building a Network CI/CD Pipeline Part 1," https://juliopdx.com/2021/10/20/building-a-network-ci/cd-pipeline-part-1/  
[2] Packet Coders. https://www.packetcoders.io/tag/blog/
