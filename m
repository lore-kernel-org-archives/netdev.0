From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv4: route: fix coding style issues net: ipv4:
 tcp: fix coding style issues
Date: Thu, 20 Dec 2012 07:31:07 -0800
Message-ID: <1356017467.21834.2838.camel@edumazet-glaptop>
References: <1356013685-31649-1-git-send-email-hasko.stevo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Hasko <hasko.stevo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:32820 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586Ab2LTPij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 10:38:39 -0500
In-Reply-To: <1356013685-31649-1-git-send-email-hasko.stevo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 15:28 +0100, Stefan Hasko wrote:
> Fix a coding style issues.
> 
> Signed-off-by: Stefan Hasko <hasko.stevo@gmail.com>
> ---
>  net/ipv4/route.c |  119 ++++++++++++++++-------------
>  net/ipv4/tcp.c   |  218 +++++++++++++++++++++++++++++++-----------------------
>  2 files changed, 194 insertions(+), 143 deletions(-)


I Nack this patch and any such patches in net/core, net/ipv4 trees for a
while.

We had too many recent changes and probably need a bunch of real fixes.

Thanks
