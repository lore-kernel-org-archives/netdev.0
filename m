From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Wed, 18 May 2011 02:37:25 -0400 (EDT)
Message-ID: <20110518.023725.441358922110721042.davem@davemloft.net>
References: <1305696161-18277-1-git-send-email-micha@neli.hopto.org>
	<20110518.020716.447947355233874982.davem@davemloft.net>
	<4DD36803.1020001@neli.hopto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: micha@neli.hopto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab1ERGh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 02:37:28 -0400
In-Reply-To: <4DD36803.1020001@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha Nelissen <micha@neli.hopto.org>
Date: Wed, 18 May 2011 08:32:35 +0200

> Op 2011-05-18 8:07, David Miller schreef:
>> From: Micha Nelissen<micha@neli.hopto.org>
>> Date: Wed, 18 May 2011 07:22:41 +0200
>>
>>> David, forgive my clumsiness, the previous patch did not compile. This
>>> one applies against 2.6.38 and does compile.
>>
>> Please send patches against the current code, not some arbitrary older
>> source tree.
> 
> I'm confused. Against which tree/commit do you want it then?

Linus's current tree would be fine as would:

	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
