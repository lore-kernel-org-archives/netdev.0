From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] bridge utilities 1.0.6
Date: Wed, 16 Mar 2005 12:38:28 -0800
Message-ID: <20050316123828.0eb78fd3@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
To: bridge@osdl.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor update to bridge utilities for 2.4/2.6. The changes are:
 + Better usage of autoconf to manage detecting sysfs library
 + Support multiple interfaces for add/delete interface commands.
	Example: brctl addif br0 eth0 eth1 eth2 
 - Remove code that was dead and no longer used

http://prdownloads.sourceforge.net/bridge/bridge-utils-1.0.6.tar.gz?download
