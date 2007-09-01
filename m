From: Satyam Sharma <satyam@infradead.org>
Subject: Re: 2.6.23-rc4-mm1 "no CRC" MODPOST warnings
Date: Sun, 2 Sep 2007 03:36:08 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709020327260.20781@enigma.security.iitk.ac.in>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:45230 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756925AbXIAVxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 17:53:01 -0400
In-Reply-To: <20070831215822.26e1432b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 31 Aug 2007, Andrew Morton wrote:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/

Got these on an i386 build with CONFIG_MODVERSIONS=y ...

WARNING: "div64_64" [net/netfilter/xt_connbytes.ko] has no CRC!
WARNING: "div64_64" [net/ipv4/tcp_cubic.ko] has no CRC!

Full .config at: http://www.cse.iitk.ac.in/users/ssatyam/config-mm
