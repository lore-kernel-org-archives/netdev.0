From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
Date: Wed, 6 Apr 2016 18:09:17 -0700
Message-ID: <5705B33D.7060808@boundarydevices.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
 <20160406.172029.2094647648319882709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com, lznuaa@gmail.com,
	fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35469 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbcDGBJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 21:09:19 -0400
Received: by mail-pf0-f178.google.com with SMTP id n1so44341420pfn.2
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 18:09:19 -0700 (PDT)
In-Reply-To: <20160406.172029.2094647648319882709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/6/2016 2:20 PM, David Miller wrote:
> 
> This is a way too large patch series.
> 
> Please split it up into smaller, more logical, pieces.
> 
> Thanks.
> 

If you apply the 1st 3 that have been acked, I'll be at 13.

Would I then send the next 5 for  V4, and when that is applied
send another V4 with the next 8 that have been already been acked?

Thanks
Troy
