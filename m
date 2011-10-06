From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] vxge: convert to SKB paged frag API.
Date: Thu, 06 Oct 2011 17:16:45 -0400 (EDT)
Message-ID: <20111006.171645.1154998655978830692.davem@davemloft.net>
References: <1317916822.21903.252.camel@zakaz.uk.xensource.com>
	<CAHXqBFJsGcAdH0zFS_Gd34oR3Ov6ssbXRMzK-KrnSxq8c3=WNg@mail.gmail.com>
	<1317935310.24742.18.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, netdev@vger.kernel.org, jdmason@kudzu.us
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759174Ab1JFVQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 17:16:50 -0400
In-Reply-To: <1317935310.24742.18.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Thu, 6 Oct 2011 22:08:30 +0100

> You are absolutely right, I've no idea how I missed the very obvious
> warning this produces. Incremental patch is below, sorry about this!

Would really love to know what your patch is against, since I
fixed this problem when I commited your original patch.
