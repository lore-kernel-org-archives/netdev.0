From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] netfilter: netfilter fixes
Date: Wed, 22 Sep 2010 13:12:32 -0700 (PDT)
Message-ID: <20100922.131232.59680750.davem@davemloft.net>
References: <1285139854-11827-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56572
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750708Ab0IVUMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:12:12 -0400
In-Reply-To: <1285139854-11827-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Wed, 22 Sep 2010 09:17:28 +0200

> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Patrick I can't pull from this, it's not based upon net-2.6

It looks like it's based upon Linus's tree, because when I pull
I get a bunch of changes that are in Linus's tree but aren't
in net-2.6

Please base all future pull requests on net-2.6, thanks.

I'll apply these patches by hand (and also this will allow me
to fix Eric's author email in that one patch).

Thanks again.


