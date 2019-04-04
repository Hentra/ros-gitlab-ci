#!/bin/bash

# https://docs.gitlab.com/ce/ci/variables/README.html

# Check CI project directory
#---------------------------
if [[ -z "$CI_PROJECT_DIR" ]]; then
  echo "CI_PROJECT_DIR variable is empty"
  exit 1
fi

# Manage self testing
#--------------------
if [[ "${CI_PROJECT_NAME}" == "ros-gitlab-ci" ]]; then
  echo "##############################################"
  SELF_TESTING="true"

  # Delete sub ROS GitLab CI repository
  rm -r $CI_PROJECT_DIR/$CI_PROJECT_NAME

  # We create a package beginner_tutorials so that the catkin workspace is not empty
  mkdir -p $CI_PROJECT_DIR/catkin_workspace/src
  cd $CI_PROJECT_DIR/catkin_workspace/src
  catkin_create_pkg beginner_tutorials std_msgs rospy roscpp
  cd $CI_PROJECT_DIR/catkin_workspace
  echo "##############################################"

  # ccache
  #-------
  if [[ -z "${DISABLE_CCACHE}" || "${DISABLE_CCACHE}" != "true" ]]; then
    source $CI_PROJECT_DIR/ccache.bash
  fi

  # Source the gitlab-ros script from the sub GitLab repository
  # This repository has the right branch
  source $CI_PROJECT_DIR/gitlab-ros.bash
else
  # ccache
  #-------
  if [[ -z "${DISABLE_CCACHE}" || "${DISABLE_CCACHE}" != "true" ]]; then
    source ros-gitlab-ci/ccache.bash
  fi

  source ros-gitlab-ci/gitlab-ros.bash
fi
