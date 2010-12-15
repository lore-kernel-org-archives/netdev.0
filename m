From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/5] ifb: fix tx_queue_len overlimit
Date: Wed, 15 Dec 2010 07:42:53 -0500
Message-ID: <1292416973.2067.15.camel@mojatatu>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	 <1292251414-5154-3-git-send-email-xiaosuo@gmail.com>
	 <1292416439.2067.6.camel@mojatatu>
	 <AANLkTi=GTo=JZ5kDEXpZDNdK1RdtirP6G8TmaJARmeL+@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41091 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab0LOMm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 07:42:56 -0500
Received: by ywl5 with SMTP id 5so988617ywl.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 04:42:55 -0800 (PST)
In-Reply-To: <AANLkTi=GTo=JZ5kDEXpZDNdK1RdtirP6G8TmaJARmeL+@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-15 at 20:36 +0800, Changli Gao wrote:

> 
> But then, we put this skb into rq in any way, and the length of rq
> becomes tx_queue_len + 1.

;->

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>


cheers,
jamal


