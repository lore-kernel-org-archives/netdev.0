From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: 82540EM very slow on 2.6.0-test[45]
Date: Wed, 10 Sep 2003 17:28:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F029@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <rwhron@earthlink.net>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> ftp'ing a multi-megabyte file gives about 16-20k/second 
> throughput.  I first noticed this on 2.6.0-test4, but
> the slowness may have existed longer.   The destination
> machine was running Solaris 8.

Linux -> Solaris

> This is a dual boot Dell P4.  XP is about 1000x faster for
> an ftp xfer, so the network seems okay.

Is this Linux -> XP or XP -> Solaris?  Trying to eliminate one player.

What about Linux -> Linux?  Is that slow?

> dmesg shows "e1000: eth0 NIC Link is Up 100 Mbps Full 
> Duplex". Here is the full dmesg log:

This feels like a duplex mis-match.  Do you have good cat 5 cables?  Are
you using the same cable for the different tests?

-scott
