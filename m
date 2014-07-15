From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next] sfc: add extra RX drop counters for nodesc_trunc
 and noskb_drop
Date: Tue, 15 Jul 2014 16:40:45 +0530
Message-ID: <53C50C35.80200@gmail.com>
References: <alpine.LFD.2.03.1407141534440.19512@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:64193 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758043AbaGOLL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 07:11:58 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so3203871pab.15
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 04:11:58 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1407141534440.19512@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 04:28 PM, Edward Cree wrote:
> Added a counter rx_noskb_drop for failure to allocate an skb.
> Summed the per-channel rx_nodesc_trunc counters earlier so that they can
>   be included in rx_dropped.
>
>
check patch errors on this patch...  :-)

-- 
Regards,
Varka Bhadram.
