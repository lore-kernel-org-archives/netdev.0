From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv6: notify userspace when we added or changed an
 ipv6 token
Date: Wed, 29 Oct 2014 14:35:56 -0400 (EDT)
Message-ID: <20141029.143556.557247523788216981.davem@davemloft.net>
References: <544D8234.5060504@redhat.com>
	<1414427956-20056-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	dborkman@redhat.com
To: lkundrak@v3.sk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbaJ2Sf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 14:35:58 -0400
In-Reply-To: <1414427956-20056-1-git-send-email-lkundrak@v3.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Mon, 27 Oct 2014 17:39:16 +0100

> NetworkManager might want to know that it changed when the router advertisement
> arrives.
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Applied, thanks.
