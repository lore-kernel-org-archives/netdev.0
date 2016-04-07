From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
Date: Wed, 06 Apr 2016 23:58:04 -0400 (EDT)
Message-ID: <20160406.235804.2223760831702758803.davem@davemloft.net>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
	<20160406.172029.2094647648319882709.davem@davemloft.net>
	<5705B33D.7060808@boundarydevices.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com, lznuaa@gmail.com,
	fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de
To: troy.kisky@boundarydevices.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbcDGD6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 23:58:08 -0400
In-Reply-To: <5705B33D.7060808@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>
Date: Wed, 6 Apr 2016 18:09:17 -0700

> On 4/6/2016 2:20 PM, David Miller wrote:
>> 
>> This is a way too large patch series.
>> 
>> Please split it up into smaller, more logical, pieces.
>> 
>> Thanks.
>> 
> 
> If you apply the 1st 3 that have been acked, I'll be at 13.
> 
> Would I then send the next 5 for  V4, and when that is applied
> send another V4 with the next 8 that have been already been acked?

What other reasonable option is there?  I can't think of any.
