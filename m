From: Sergey Lapin <slapin@ossfans.org>
Subject: [PULL REQUEST] IEEE 802.15.4 stack: generic parts v3
Date: Sun, 7 Jun 2009 06:23:23 +0400
Message-ID: <20090607022323.GE576@build.ossfans.org>
References: <cover.1244337432.git.slapin@ossfans.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from build.ossfans.org ([67.223.233.67]:51028 "EHLO
	build.ossfans.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbZFGCXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2009 22:23:30 -0400
Content-Disposition: inline
In-Reply-To: <cover.1244337432.git.slapin@ossfans.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 07, 2009 at 05:18:29AM +0400, Sergey Lapin wrote:
> Hello,
> 
> This is a third version of pull/merge request for IEEE 802.15.4 stack.
> 
> As per Dmitry request I'm taking over passing this patchset through
> review. This is my first pull request through mail lists, so I might
> do some mistakes, but I hope I did not miss any.
> 
> Major changes from previous post:
>  * Fixed email addresses for Sergey Lapin.
  * removed code, whic depends on __KERNEL__ preprocessor macro part
    from netlink code

I've forgot to note, __KERNEL__ handling part is present in this patch
set too. Sorry, that's what happens because of takeover business.
Hope, I don't need to resubmit the whole thing because of that.

