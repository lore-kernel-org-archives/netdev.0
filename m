From: David Miller <davem@davemloft.net>
Subject: Re: NULL dereference in econet AUN-over-UDP receive
Date: Wed, 08 Dec 2010 20:50:31 -0800 (PST)
Message-ID: <20101208.205031.193717966.davem@davemloft.net>
References: <1291858667.2795.16.camel@edumazet-laptop>
	<20101208.180215.193709862.davem@davemloft.net>
	<AANLkTimdN2LkEpyWV0bsdfVVvnsQOaLGYmm_0ostrjFM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nelhage@ksplice.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43975
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754254Ab0LIEuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 23:50:04 -0500
In-Reply-To: <AANLkTimdN2LkEpyWV0bsdfVVvnsQOaLGYmm_0ostrjFM@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson Elhage <nelhage@ksplice.com>
Date: Wed, 8 Dec 2010 23:18:22 -0500

> Yep, that fixes the crash.
> 
> Tested-by: Nelson Elhage <nelhage@ksplice.com>

THanks for testing.
