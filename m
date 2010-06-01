From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter: netfilter fixes
Date: Mon, 31 May 2010 23:45:11 -0700 (PDT)
Message-ID: <20100531.234511.241910061.davem@davemloft.net>
References: <1275322487-19026-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752240Ab0FAGpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 02:45:01 -0400
In-Reply-To: <1275322487-19026-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Mon, 31 May 2010 18:14:45 +0200

> the following two patches fix two problems with the recent introduction of
> a seperately allocated jumpstack for xtables rulesets:
> 
> - a memory leak when registering new tables, from Xiaotian Feng
> 
> - performance degradation caused by not using per-CPU allocations
>   for the jumpstack, from Eric
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks Patrick.
