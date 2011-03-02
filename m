From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] netfilter: netfilter update
Date: Wed, 02 Mar 2011 11:30:44 -0800 (PST)
Message-ID: <20110302.113044.226764702.davem@davemloft.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39144
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754516Ab1CBTaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 14:30:07 -0500
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Wed,  2 Mar 2011 13:12:40 +0100

> following is a netfilter update for net-next, containing:
> 
> - minor cleanups and bugfixes
> 
> - a fix for a bridge netfilter information leak, from Vasiliy Kulikov
> 
> - IPVS timer fixes, from Tinggong Wang
> 
> - conversion of the IPVS hash table to hlists, from Changli
> 
> - TCP conntrack improvements, from Pablo
> 
> Please pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Also pulled, thanks!
