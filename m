From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 2/6] be2net: pass if_id for v1 and V2 versions of
 TX_CREATE cmd
Date: Fri, 11 Oct 2013 15:02:16 -0400 (EDT)
Message-ID: <20131011.150216.1046004842312207634.davem@davemloft.net>
References: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
	<1380623401-15630-3-git-send-email-sathya.perla@emulex.com>
	<CF9D1877D81D214CB0CA0669EFAE020C26A275D8@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237Ab3JKTCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 15:02:17 -0400
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C26A275D8@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <Sathya.Perla@Emulex.Com>
Date: Thu, 10 Oct 2013 10:53:41 +0000

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf
>> 
>> From: Vasundhara Volam <vasundhara.volam@emulex.com>
>> 
>> It is a required field for all TX_CREATE cmd versions > 0.
>> Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
>> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> 
> David, Could you pls queue this patch for the stable tree.

I have a better idea, can you guys actually submit patches to the
proper destination?

If it's a bug fix, send it to 'net'.  If it's not in 'net' I'm
not submitting it to -stable.
