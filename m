From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 0/11] Add MODULE_VERSION to several network drivers
Date: Wed, 20 Oct 2004 14:11:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020141146.C8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com, akpm@osdl.org,
        romieu@fr.zoreil.com, ctindel@users.sourceforge.net, fubar@us.ibm.com,
        greearb@candelatech.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patches to add MODULE_VERSION lines to several network drivers...

Here is the list:

	tg3
	e100
	e1000
	b44
	tulip
	3c59x
	8139too
	ns83820
	r8169
	bonding
	vlan

Individual patches to follow...

John
-- 
John W. Linville
linville@tuxdriver.com
