From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][v3.13.y] e1000e: Fix no connectivity when driver loaded with
 cable out
Date: Wed, 17 Dec 2014 12:08:30 -0500
Message-ID: <5491B88E.3070906@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "stable@vger.kernel.org" <stable@vger.kernel.org>,
	davidx.m.ertman@intel.com, jeffrey.e.pieper@intel.com,
	jeffrey.t.kirsher@intel.com, LKML <linux-kernel@vger.kernel.org>,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kamal Mostafa <kamal.mostafa@canonical.com>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Please consider including mainline commit b20a774 in the next v3.13.y
stable release.  It was included in the mainline tree as of v3.15-rc1. 
It has been tested and confirmed to resolve
http://bugs.launchpad.net/bugs/1400365 .

commit b20a774495671f037e7160ea2ce8789af6b61533
Author: David Ertman <davidx.m.ertman@intel.com>
Date:   Tue Mar 25 04:27:55 2014 +0000

    e1000e: Fix no connectivity when driver loaded with cable out



Sincerely,
Joseph Salisbury
