From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 0/10] e1000: driver update
Date: Tue, 15 Feb 2005 13:24:16 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151039110.30336-100000@isotope.jf.intel.com>
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
1 Robert Olsson's fix and refinement to the poll routine
2 use netif_poll_{enable|disable}
3 Avoid race between e1000_watchdog and e1000_clean_tx_irq
4 Delay clean-up of last Tx buffer
5 Fix WOL settings in 82544 based adapters
6 Patch from Peter Kjellstroem -- fix lockup with 82547
7 Checks for desc ring/rx data bufs spanning 64k boundary
8 Report failure code when loopback test fails
9 Fixes related to Cable length estimation
10 Driver version white space, device id, comments & other
