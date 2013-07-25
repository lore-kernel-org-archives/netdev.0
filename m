From: Joe Stringer <joe@wand.net.nz>
Subject: Re: [net-next] net: Add NEXTHDR_SCTP to ipv6.h
Date: Thu, 25 Jul 2013 10:18:27 +0900
Message-ID: <CAOftzPiuOyX869_g=NnAfHRatAwmZ=fYVzpmTk_ijZdfyH36ng@mail.gmail.com>
References: <1374554265-10611-1-git-send-email-joe@wand.net.nz> <20130724.174219.372069002030719666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joe Stringer <joe@wand.net.nz>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, Simon Horman <horms@verge.net.au>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:57394 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3GYBSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 21:18:48 -0400
Received: by mail-oa0-f51.google.com with SMTP id i4so2877413oah.10
        for <netdev@vger.kernel.org>; Wed, 24 Jul 2013 18:18:48 -0700 (PDT)
In-Reply-To: <20130724.174219.372069002030719666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Understood.

On Thu, Jul 25, 2013 at 9:42 AM, David Miller <davem@davemloft.net> wrote:
> From: Joe Stringer <joe@wand.net.nz>
> Date: Tue, 23 Jul 2013 13:37:45 +0900
>
>> Signed-off-by: Joe Stringer <joe@wand.net.nz>
>
> There is no value in adding a kernel internal define that is
> completely unused.
>
> Sorry I won't be applying this patch.
