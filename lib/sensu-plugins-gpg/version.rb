# SensuPluginsGpg is the main module
module SensuPluginsGpg
  # Version holds details about version number. It consists of
  # three elements which are major, minor and patch number.
  module Version
    # Major version number (X.0.0)
    MAJOR = 3
    # Minor version number (0.X.0)
    MINOR = 0
    # Patch version number (0.0.X)
    PATCH = 0
    # Version number (X.X.X)
    VER_STRING = [MAJOR, MINOR, PATCH].compact.join('.')
  end
end
