From: Dan Williams <dcbw@redhat.com>
Subject: [PATCHES] wireless: Update in-kernel orinoco driver
Date: Tue, 26 Oct 2004 14:12:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This series of 15 patches updates the in-kernel orinoco wireless drivers
to the level of current upstream orinoco CVS (from sourceforge).  This
level is "0.15rc2HEAD" as found in orinoco.h.

The basis for this patchset was:

upstream orinoco CVS from Mon, Oct 25
kernel sources from linux-2.6.9.tar.bz2 + patch-2.6.10-rc1.bz2

This is a revival of an effort to get the drivers up-to-date from
earlier this year in July.

Dan
