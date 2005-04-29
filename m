From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 0/11] ixgb: driver update
Date: Thu, 28 Apr 2005 18:42:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281840370.27952-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
 
1.  Fix multi-cast packet count in statistics 
2.  Do not set the RS bit on context descriptors
3.  Change RDT write bump size back to 4
4.  Mask RXO interrupt 
5.  Reset status in the Rx descriptor prior to handing it to the controller
6.  Fix EEPROM functions to be endian-aware
7.  Support for ethtool -d
8.  Remove hook for suspend. No power management in 10GbE Controllers
9.  Code optimization
10. Fixed msec_delay in osdep to use msleep
11. Driver version, white space, comments, device id & other
