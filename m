From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] div64_64: common code
Date: Tue, 06 Mar 2007 10:11:40 -0800 (PST)
Message-ID: <20070306.101140.101595874.davem@davemloft.net>
References: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	chris@zankel.net, geert@linux-m68k.org, jdike@addtoit.com,
	ralf@linux-mips.org, rmk@arm.linux.org.uk, zippel@linux-m68k.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965453AbXCFSLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 13:11:43 -0500
In-Reply-To: <200703061042.l26AgS0U019809@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Tue, 06 Mar 2007 02:42:28 -0800

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Implement div64_64(): 64-bit by 64-bit division.  Needed by networking (at
> least).

This patch, with the types.h fixes of your's, is already in my
net-2.6.22 GIT tree if you'd like to start pulling from there
Andrew.
