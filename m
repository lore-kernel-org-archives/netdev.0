From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixp4xx: Support the all multicast flag on the NPE
 devices.
Date: Tue, 01 Jun 2010 00:18:55 -0700 (PDT)
Message-ID: <20100601.001855.71558565.davem@davemloft.net>
References: <m3pr0c17ue.fsf@intrepid.localdomain>
	<20100531153419.GA17317@riccoc20.at.omicron.at>
	<m3typoyr86.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42463
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753401Ab0FAHSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:18:46 -0400
In-Reply-To: <m3typoyr86.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 31 May 2010 18:24:09 +0200

> Richard Cochran <richardcochran@gmail.com> writes:
> 
>> This patch adds support for the IFF_ALLMULTI flag. Previously only the
>> IFF_PROMISC flag was supported.
>>
>> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
 ...
> Acked-By: Krzysztof Halasa <khc@pm.waw.pl>

Applied.
