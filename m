From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.20] [TCP] MD5 Signature Option (RFC2385) support.
Date: Tue, 14 Nov 2006 19:39:40 -0800 (PST)
Message-ID: <20061114.193940.18303952.davem@davemloft.net>
References: <20061110.171521.70104616.yoshfuji@linux-ipv6.org>
	<20061113.150718.58788536.davem@davemloft.net>
	<20061114.070636.88795229.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1477
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966024AbWKODjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 22:39:39 -0500
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061114.070636.88795229.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 14 Nov 2006 07:06:36 -0800 (PST)

> Good point, I agree.
> 
> Here's the updated and rebased patch.
> 
> >From a3dea6a6b127b3d38932677c8da854b62a20540e Mon Sep 17 00:00:00 2001
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Tue, 14 Nov 2006 09:57:39 +0900
> Subject: [PATCH] [TCP]: MD5 Signature Option (RFC2385) support.
> 
> Based on implementation by Rick Payne.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Looks great, patch applied, thanks a lot.
