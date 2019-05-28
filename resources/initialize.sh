#!/usr/bin/env bash

# Let the healthcheck complete once, then wipe it out
${DATADIR}/scripts/init.sh && echo '#!/usr/bin/env bash' > ${DATADIR}/initialize.sh
