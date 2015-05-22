From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 03/11] net: Remove superfluous setting of
 key_basic
Date: Fri, 22 May 2015 08:37:52 +0200
Message-ID: <20150522063752.GC2138@nanopsycho.orion>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
 <1432253506-3646977-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34311 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbbEVGhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 02:37:55 -0400
Received: by wicmc15 with SMTP id mc15so31697145wic.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 23:37:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432253506-3646977-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 22, 2015 at 02:11:38AM CEST, tom@herbertland.com wrote:
>key_basic is set twice in __skb_flow_dissect which seems unnecessary.
>Remove second one.
>
>Signed-off-by: Tom Herbert <tom@herbertland.com>

I have the same patch in my queue :)

Acked-by: Jiri Pirko <jiri@resnulli.us>
