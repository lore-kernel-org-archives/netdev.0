From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] net: rps: fix the support for PPPOE
Date: Wed, 28 Sep 2011 13:35:56 -0400 (EDT)
Message-ID: <20110928.133556.328877307187038463.davem@redhat.com>
References: <1316594167-12313-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433Ab1I1Rf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 13:35:59 -0400
In-Reply-To: <1316594167-12313-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 21 Sep 2011 16:36:07 +0800

> The upper protocol numbers of PPPOE are different, and should be treated
> specially.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
