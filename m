From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Neterion: *FIFO1_DMA_ERR set twice, should 2nd be
 *FIFO2_DMA_ERR?
Date: Sun, 17 May 2009 21:18:32 -0700 (PDT)
Message-ID: <20090517.211832.28119846.davem@davemloft.net>
References: <4A0DCE67.70106@gmail.com>
	<78C9135A3D2ECE4B8162EBDCE82CAD7705444A38@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36522
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750739AbZERESe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:18:34 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705444A38@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Sun, 17 May 2009 03:52:59 -0400

>> FIFO1_DMA_ERR is set twice, the second should be FIFO2_DMA_ERR.
>> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
...
> Acked-by: Ram Vepa <ram.vepa@neterion.com>

Applied, thanks!
