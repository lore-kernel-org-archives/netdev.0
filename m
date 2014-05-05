From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [Patch net-next] net: rename local_df to ignore_df
Date: Sun, 4 May 2014 20:03:32 -0700
Message-ID: <CANP3RGexX=73J4ms42O4bG3bP3v0-+UtejNZLKPJBbc7RnoCHA@mail.gmail.com>
References: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:37641 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbaEEDDd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 23:03:33 -0400
Received: by mail-qg0-f41.google.com with SMTP id j5so165204qga.14
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 20:03:32 -0700 (PDT)
In-Reply-To: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>

Although this'll likely collide with the netfilter patch which adds
another use of local_df.
