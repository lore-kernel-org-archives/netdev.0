From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 0/5] ixgb: driver update
Date: Tue, 15 Feb 2005 13:37:00 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151158240.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
1 use netif_poll_{enable|disable}
2 Avoid race e1000_watchdog and ixgb_clean_tx_irq
3 Robert Olsson's fix and refinement to the poll routine
4 Invalidate software cache, when writing EEPROM.
5 Driver version, white space, comments, device id & other
	
