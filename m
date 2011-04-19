From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter: netfilter update
Date: Tue, 19 Apr 2011 11:28:03 -0700 (PDT)
Message-ID: <20110419.112803.102559508.davem@davemloft.net>
References: <1303223492-13549-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752663Ab1DSS2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 14:28:37 -0400
In-Reply-To: <1303223492-13549-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Tue, 19 Apr 2011 16:31:29 +0200

> following is a small netfilter update for net-next, containing:
> 
> - a patch from Eric to remove some atomic ops in the *tables fastpath
> 
> - removal of an unnecessary ifdef from IPVS by Simon
> 
> - SCTP and UDPLITE support for ipset, from Jozsef
> 
> Please pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Pulled, thanks!
