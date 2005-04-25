From: "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 0/11] ixgb: driver update
Date: Mon, 25 Apr 2005 10:41:35 -0700
Message-ID: <331AD7BED1579543AD146F5A1A44D52506DF284C@fmsmsx403.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Mallikarjuna R Chilakala
<mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

1.  Fix multi-cast packet count in statistics
2.  Do not set the RS bit on context descriptors
3.  Change RDT write bump size back to 4
4.  Mask RXO interrupt
5.  Reset status in the Rx descriptor prior to handing it to the
controller
6.  Fix EEPROM functions to be endian-aware
7.  Support for ethtool -d
8.  Remove hook for suspend. No power management in 10GbE Controllers
9.  Code optimization
10. Fixed msec_delay in osdep to use msleep
11. Driver version, white space, comments, device id & other
