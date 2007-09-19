From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Wed, 19 Sep 2007 11:11:47 -0700 (PDT)
Message-ID: <20070919.111147.55510143.davem@davemloft.net>
References: <20070917.190527.42775386.davem@davemloft.net>
	<1190081655.19708.255.camel@localhost>
	<1190177401.19708.264.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33153
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750839AbXISSLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 14:11:47 -0400
In-Reply-To: <1190177401.19708.264.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 18 Sep 2007 21:50:01 -0700

> I rebased against yesterday's net-2.6.24
> 
> Please pull from:
> 
> git://repo.or.cz/linux-2.6/trivial-mods.git net-2.6.24-fordave

You didn't "rebase" you "merged" and this makes your tree a complete
mess.

When you do a real "rebase", you clone a fresh new tree from mine and
add only your patches on top.

Your tree as-is is difficult for me to pull from because it contains
all kinds of messy merges and merge error fixups.

Can you just extract out one single patch that does the MAC_FMT change
and get that to me somehow?  Either by adding it into a fresh
net-2.6.24 clone, or as a patch.  Both ways are fine.
