From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 0/11] huge patch bomb
Date: Mon, 8 Sep 2003 20:13:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309082000360.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff, new device support held this patch set up.  :-(

The new 82541/5/6/7 devices fix some hardware bugs, including handling
PCI-X MMRBC correctly, and not requiring IO-mapping to issue reset.  Also
adds new internal SERDES device support for backplane applications.

Other bugs fixes for legacy 82544x controllers included.  See patches for 
details.

These are for 2.6.0-test4.  I'll send 2.4.x sync patches under separate
cover.

-scott
