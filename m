From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for October 31 (repeat build failures)
Date: Fri, 31 Oct 2008 13:28:39 -0700
Message-ID: <20081031132839.8c07b0aa.randy.dunlap@oracle.com>
References: <20081031185613.7892fd8d.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, gregkh <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:26005 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbYJaU3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 16:29:10 -0400
In-Reply-To: <20081031185613.7892fd8d.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Oct 2008 18:56:13 +1100 Stephen Rothwell wrote:

The only randconfig build failures that I see today (on i386 & x86_64)
are repeats of:

hp-plus undefined references:
  http://marc.info/?l=linux-next&m=122513607505680&w=2

staging/go7007/go7007-v4l2:
  http://marc.info/?l=linux-next&m=122513515404158&w=2

net/9p rdma_* undefined references with CONFIG_NET=y and CONFIG_INET=n:
  http://marc.info/?l=linux-next&m=122504699904105&w=2

---
~Randy
