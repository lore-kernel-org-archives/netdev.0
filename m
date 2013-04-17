From: joseph.salisbury@canonical.com
Subject: [PATCH 0/1] [v3.8.y] tg3: Add 57766 device support.
Date: Wed, 17 Apr 2013 15:19:12 -0400
Message-ID: <cover.1365020650.git.joseph.salisbury@canonical.com>
Cc: stable@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joseph Salisbury <joseph.salisbury@canonical.com>

BugLink: http://bugs.launchpad.net/bugs/1162665

Please consider including upstream commit d3f677afb8076d09d090ff0a5d1229c9dd9f136e in the next v3.8.y release.  It was included upstream as of v3.9-rc1.  It has been tested and confirmed to resolve http://bugs.launchpad.net/bugs/1162665 .

commit d3f677afb8076d09d090ff0a5d1229c9dd9f136e
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Thu Feb 14 14:27:51 2013 +0000

    tg3: Add 57766 device support.

This commit does not apply cleanly to v3.8, so I performed a backport, which is in email 1/1.




Matt Carlson (1):
  tg3: Add 57766 device support.

 drivers/net/ethernet/broadcom/tg3.c |   18 +++++++++++++++++-
 drivers/net/ethernet/broadcom/tg3.h |    2 ++
 2 files changed, 19 insertions(+), 1 deletion(-)

-- 
1.7.9.5
