From: David Miller <davem@davemloft.net>
Subject: Re: netfilter: xt_limit: fix invalid return code in
 limit_mt_check()
Date: Mon, 23 Nov 2009 09:53:14 -0800 (PST)
Message-ID: <20091123.095314.117228474.davem@davemloft.net>
References: <4B0A838D.3020907@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36841
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbZKWRw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 12:52:56 -0500
In-Reply-To: <4B0A838D.3020907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 23 Nov 2009 13:43:57 +0100

> This patch fixes an invalid return value in the limit match.
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Pulled, thanks Patrick.
