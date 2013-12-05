From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] be2net fixes
Date: Thu, 05 Dec 2013 01:28:13 -0500 (EST)
Message-ID: <20131205.012813.2201475304685818121.davem@davemloft.net>
References: <7F44EA5110810A40B7DAFB605C41975D2C96274B@CMEXMB1.ad.emulex.com>
	<20131205.003925.220601244226026270.davem@davemloft.net>
	<7F44EA5110810A40B7DAFB605C41975D2C96279B@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Somnath.Kotur@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab3LEG2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 01:28:16 -0500
In-Reply-To: <7F44EA5110810A40B7DAFB605C41975D2C96279B@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Date: Thu, 5 Dec 2013 06:24:10 +0000

>> This is absolutely not something an individual driver should decide to do,
>> _EVERY_ driver has this issue.
> 
> OK, Understood, guess you want this to ideally be handled somewhere up in the stack/framework?

I think it's pointless to do at all.
