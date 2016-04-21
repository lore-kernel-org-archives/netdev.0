From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: Split SW RX dropped counter per RX ring
Date: Thu, 21 Apr 2016 07:52:43 +0300
Message-ID: <CAJ3xEMgyAyp+2g+b1wEGGVGSWMwf8CGSCmRZLBMztTRVHKcgfA@mail.gmail.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
	<1461157278-18528-5-git-send-email-ogerlitz@mellanox.com>
	<1461164209.10638.262.camel@edumazet-glaptop3.roam.corp.google.com>
	<571799A3.402@mellanox.com>
	<1461200550.7627.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36400 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbcDUEwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 00:52:44 -0400
Received: by mail-io0-f176.google.com with SMTP id u185so74697449iod.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 21:52:43 -0700 (PDT)
In-Reply-To: <1461200550.7627.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 4:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-04-20 at 18:00 +0300, Or Gerlitz wrote:

>> Just to be sure, you'd like me to re-spin this and fix the reporter name?

> Absolutely not, I believe patchwork should handle this just fine.
> Patchwork does not understand the "Fixes:" tag yet, but Reported-by: is
> fine.

OK, Eric and Florian, thanks for clarifying this out.

Or.
