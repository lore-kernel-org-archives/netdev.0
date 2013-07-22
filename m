From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Mon, 22 Jul 2013 12:28:01 -0700
Message-ID: <1374521281.4990.34.camel@edumazet-glaptop>
References: <1374520422.4990.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:53999 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932676Ab3GVT2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 15:28:05 -0400
Received: by mail-pa0-f44.google.com with SMTP id lj1so7410410pab.3
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 12:28:04 -0700 (PDT)
In-Reply-To: <1374520422.4990.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 12:13 -0700, Eric Dumazet wrote:
> TCP_NOSENT_LOWAT

For an unknown reason, this was spelled incorrectly

I'll send a V2 with TCP_NOTSENT_LOWAT
