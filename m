From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v2] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for local udp tunneled skbs
Date: Mon, 18 Jul 2016 13:11:11 +0300
Message-ID: <20160718131111.6d4c0540@pixies>
References: <1468582987-18990-1-git-send-email-shmulik.ladkani@gmail.com>
	<27e9a6c3-1648-892c-bcaa-254e5332a42e@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34840 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbcGRKLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 06:11:22 -0400
Received: by mail-wm0-f46.google.com with SMTP id f65so96544292wmi.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 03:11:22 -0700 (PDT)
In-Reply-To: <27e9a6c3-1648-892c-bcaa-254e5332a42e@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jul 2016 12:06:00 +0200, hannes@stressinduktion.org wrote:
> > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> I think this is reasonable, thanks!
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks for the feedback and assistance.

I'll spin a v3 with a tiny coding change.

Regards,
Shmulik
