From: David Miller <davem@davemloft.net>
Subject: Re: [patch] caif: fix a couple range checks
Date: Wed, 09 Jun 2010 16:19:14 -0700 (PDT)
Message-ID: <20100609.161914.104048741.davem@davemloft.net>
References: <20100607145158.GO5483@bicker>
	<81C3A93C17462B4BBD7E272753C10579169C4D9E64@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752747Ab0FIXTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 19:19:03 -0400
In-Reply-To: <81C3A93C17462B4BBD7E272753C10579169C4D9E64@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Date: Wed, 9 Jun 2010 11:11:38 +0200

>> From: Dan Carpenter [mailto:error27@gmail.com]
>> 
>> The extra ! character means that these conditions are always false.
> 
> 
> Looks good, thanks. This is embarrassing, I should caught this ages ago.
> Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied, thanks guys.
