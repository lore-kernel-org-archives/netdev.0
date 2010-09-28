From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: Implement Any-IP support for IPv6.
Date: Tue, 28 Sep 2010 14:04:47 -0700
Message-ID: <AANLkTim05yqEiN+LbL5d3Eear0WMcG5LtCi5Ba_StvYv@mail.gmail.com>
References: <1285582022-30787-1-git-send-email-zenczykowski@gmail.com>
	<20100928.135923.59699712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53102 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127Ab0I1VEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 17:04:49 -0400
Received: by wyb28 with SMTP id 28so95288wyb.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 14:04:47 -0700 (PDT)
In-Reply-To: <20100928.135923.59699712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AFAIK, Tom Herbert did post the ipv4 patch some time back.

http://patchwork.ozlabs.org/patch/53381/

I think the ipv6 code path (and hence the patch itself) is much cleaner.
