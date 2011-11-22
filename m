From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net-netlink: fix diag to export IPv4 tos for dual-stack
 IPv6 sockets
Date: Mon, 21 Nov 2011 17:52:09 -0800
Message-ID: <CAHo-OoxNkDvuTJWfz=Q6XxS_gJyf-w_A=V_3Qi8hL_k5-18RPg@mail.gmail.com>
References: <CAHo-OozYtgN9_TdOTs+40JKpSZmi2c-6yrbjFS2hViFv_QY-5Q@mail.gmail.com>
	<1321926620-28753-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Murali Raja <muralira@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60559 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab1KVBwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 20:52:09 -0500
Received: by ggnr5 with SMTP id r5so3026768ggn.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 17:52:09 -0800 (PST)
In-Reply-To: <1321926620-28753-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As you see, I've decided to go with the simplest 'punt the problem to
userspace' solution.

Hope this is acceptable...

- Maciej
