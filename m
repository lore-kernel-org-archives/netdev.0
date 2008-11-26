From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 32/53] netns xfrm: finding policy in netns
Date: Tue, 25 Nov 2008 17:34:27 -0800 (PST)
Message-ID: <20081125.173427.194859511.davem@davemloft.net>
References: <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-31-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-32-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752773AbYKZBe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:34:28 -0500
In-Reply-To: <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:27:04 +0300

> Add netns parameter to xfrm_policy_bysel_ctx(), xfrm_policy_byidx().
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
