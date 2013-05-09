From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] gso: Handle Trans-Ether-Bridging protocol in
 skb_network_protocol()
Date: Wed, 08 May 2013 19:49:45 -0700
Message-ID: <1368067785.13473.72.camel@edumazet-glaptop>
References: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
	 <20130508.131547.1016073329398924443.davem@davemloft.net>
	 <CALnjE+rkpy2vC84L2koq93=ZqHe3fN_1A-09yh=ugFMXBnzM3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	amwang@redhat.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:57605 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab3EICtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 22:49:47 -0400
Received: by mail-da0-f46.google.com with SMTP id e20so1330578dak.33
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 19:49:47 -0700 (PDT)
In-Reply-To: <CALnjE+rkpy2vC84L2koq93=ZqHe3fN_1A-09yh=ugFMXBnzM3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-08 at 19:32 -0700, Pravin Shelar wrote:

> Hi David,
> Can you queue this patch for -stable ?

BTW you should always include in the changelog :

Bug added in commit 121212121212
("foo: some fancy patch")

This eases David and all stable/distro guys work.

Thanks
