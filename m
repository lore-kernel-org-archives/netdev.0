From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] net: suppress warnings on dev_alloc_skb
Date: Thu, 19 May 2016 08:42:07 -0700
Message-ID: <1463672527.18194.193.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
	 <1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32913 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932289AbcESPmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 11:42:11 -0400
Received: by mail-pf0-f195.google.com with SMTP id y7so8514808pfb.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 08:42:10 -0700 (PDT)
In-Reply-To: <1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 11:30 -0400, Neil Horman wrote:
> Noticed an allocation failure in a network driver the other day on a 32 bit
> system:

> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Alexander Duyck <alexander.duyck@gmail.com>

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Neil
