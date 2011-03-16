From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/01] netfilter: netfilter fix for net-next
Date: Wed, 16 Mar 2011 11:12:55 -0700 (PDT)
Message-ID: <20110316.111255.39178821.davem@davemloft.net>
References: <1300297111-28116-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753150Ab1CPSMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 14:12:18 -0400
In-Reply-To: <1300297111-28116-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Wed, 16 Mar 2011 18:38:30 +0100

> following is a single netfilter fix from Thomas for net-next. The new
> AUDIT target is supposed to work with ebtables, however it returns
> a xtables verdict, which are unfortunately incompatible with ebtables
> verdicts.
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

I'll pull this, thanks Patrick.

