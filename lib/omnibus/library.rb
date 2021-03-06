#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Omnibus
  #
  # Used to generate the manifest of all software components with versions
  class Library

    def initialize
      @projects = []
      @components = []
    end

    def component_added(component)
      @components << component
    end

    def version_map(project)
      @components.select {|c| c.project == project}.inject({}) {|map, component|
        map[component.name] = if component.given_version
                                {:version       => component.version,
                                 :given_version => component.given_version,
                                 :overridden    => component.overridden?,
                                 :version_guid  => component.version_guid}
                              else
                                ## Components without a version are
                                ## pieces of the omnibus project
                                ## itself, and so don't really fit
                                ## with the concept of overrides
                                v = {:version => project.build_version}
                                if project.build_version.respond_to?(:git_sha)
                                  v[:version_guid] = "git:#{project.build_version.git_sha}"
                                end
                                v
                              end
        map
      }
    end

    def select(*args, &block)
      @components.select(*args, &block)
    end


  end

  def self.library
    @library ||= Library.new
  end

  def self.component_added(*args)
    library.component_added(*args)
  end

end

