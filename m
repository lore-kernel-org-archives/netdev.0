From: Aurelien Jarno <aurelien@aurel32.net>
Subject: [PATCH 0/4][SSB] Broadcom MIPS core driver
Date: Mon, 6 Aug 2007 01:17:04 +0200
Message-ID: <20070805231704.GA13927@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Felix Fietkau <nbd@openwrt.org>
To: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:47687 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757751AbXHEX4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 19:56:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches fix and improve the SSB Broadcom MIPS core driver
in order to support the BCM947xx CPUs.

Patch #1: EXTIF timing initialization
Patch #2: EXTIF serial port initialization 
Patch #3: MIPS core flash driver
Patch #4: Implement ssb_cpu_clock()

Cc: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

-- 
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
