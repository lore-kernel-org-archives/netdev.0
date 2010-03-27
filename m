From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.34-rc2] pcnet_cs: add new id
Date: Sat, 27 Mar 2010 16:56:36 -0700 (PDT)
Message-ID: <20100327.165636.70191811.davem@davemloft.net>
References: <20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754268Ab0C1ADf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 20:03:35 -0400
In-Reply-To: <20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Sun, 28 Mar 2010 05:55:37 +0900

> 
> pcnet_cs:
>  *add new id (Allied Telesis LM33-PCM-T Lan&Modem multifunction card)
>  *use PROD_ID for LA-PCM.(because LA-PCM and LM33-PCM-T use the same MANF_ID).
> 
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied, thanks Ken.
