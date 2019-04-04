[![ROS](http://www.ros.org/wp-content/uploads/2013/10/rosorg-logo1.png)](http://www.ros.org/)

Using Travis CI? Take a look at [ros-industrial/industrial_ci](https://github.com/ros-industrial/industrial_ci).

## Description
This repository contains helper scripts and instructions on how to use Continuous Integration (CI) for ROS projects hosted on a GitLab instance.

Supported ROS releases:
- Indigo
- Jade
- Kinetic
- Lunar
- Melodic

This repository uses the [ROS Docker](https://store.docker.com/images/ros) images to compile your packages, it does not run tests by default.

## How to use
Your repository must be hosted on a GitLab instance with CI working and Docker support.

Create a `.gitlab-ci.yml` that looks like this:

```yml
image: ros:melodic-ros-core

cache:
  paths:
    - ccache/

before_script:
  - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
  - source ros_gitlab_ci/gitlab-ci.bash >/dev/null

catkin_make:
  stage: build
  script:
    - catkin_make

catkin tools:
  stage: build
  script:
    - catkin build --summarize --no-status --force-color
```
Commit, push to your repository and watch the pipeline! (make sure pipelines are enabled in your project settings).

If you want to test your packages after building them, read the [example package](#example-package-with-testing) section.

## Useful variables
- `ROS_PACKAGES_TO_INSTALL` (empty by default) specify extra ROS packages to install, for `ros-kinetic-rviz` just add `rviz` to the list, the ROS distro is automatically detected.
- `GLOBAL_C11` (not defined by default), if defined to `true`: forces C++11 for every project compiled, defined it to any value (eg `true`) to globally enable C++11.
- `DISABLE_GCC_COLORS` (false by default), if defined to `true`: disables gcc colour output ([-fdiagnostics-color](https://gcc.gnu.org/onlinedocs/gcc/Diagnostic-Message-Formatting-Options.html)).
- `DISABLE_CCACHE` (false by default), if defined to `true`: disables [ccache](https://ccache.samba.org/) gcc output caching.
- `USE_ROSDEP` (true by default) use [rosdep](http://wiki.ros.org/rosdep/) to install dependencies. Define to `false` to disable.
- `ROSINSTALL_CI_JOB_TOKEN` (false by default), if defined to `true`: makes it possible to clone private repositories using wstool by using the [CI job permissions mode](https://docs.gitlab.com/ee/user/project/new_ci_build_permissions_model.html). Requires GitLab 8.12 minimum and that the private repositories are on the same GitLab server.
- `WSTOOL_RECURSIVE` (false by default), if defined to `true`: wstool will be used to cloned recursively every repositories specified in the `*.rosinstall` files. For this feature to work:
  - The rosinstall file names must be unique
  - No repository may contain a space in it's name

Example of using one of the available variables:
```yml
image: ros:melodic-ros-core

variables:
  ROS_PACKAGES_TO_INSTALL: "uuid-msgs"

before_script:
  - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
  - source ros_gitlab_ci/gitlab-ci.bash >/dev/null

catkin_make:
  stage: build
  script:
    - catkin_make
```

## Installing extra APT packages
Just add them after sourcing `gitlab-ci.bash` in the `before_script` section, for example:

```yml
before_script:
 - git clone https://gitlab.com/VictorLamoine/ros_gitlab_ci.git
 - source ros_gitlab_ci/gitlab-ci.bash >/dev/null
 - apt install -y liblapack-dev >/dev/null
```

## Using with [`catkin_lint`](http://wiki.ros.org/catkin_lint)
Example usage:
```yml
# catkin_lint
catkin lint:
  stage: build
  image: ros:melodic-ros-core
  before_script:
    - apt update >/dev/null 2>&1
    - apt install -y python-catkin-lint >/dev/null 2>&1
  allow_failure: true
  script:
    - catkin_lint -W3 .
```


## Example package with testing
You can also test you packages using the ROS testing tools and GitLab CI pipelines, here is an example package:
- https://gitlab.com/VictorLamoine/ros_gitlab_ci_test
- https://gitlab.com/VictorLamoine/ros_gitlab_ci_test/blob/melodic/.gitlab-ci.yml
