From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-netlink: fix diag to export IPv4 tos for
 dual-stack IPv6 sockets
Date: Tue, 22 Nov 2011 16:03:43 -0500 (EST)
Message-ID: <20111122.160343.694734684435324950.davem@davemloft.net>
References: <CAHo-OozYtgN9_TdOTs+40JKpSZmi2c-6yrbjFS2hViFv_QY-5Q@mail.gmail.com>
	<1321926620-28753-1-git-send-email-zenczykowski@gmail.com>
	<CAHo-OoxNkDvuTJWfz=Q6XxS_gJyf-w_A=V_3Qi8hL_k5-18RPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com, muralira@google.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab1KVVDr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 16:03:47 -0500
In-Reply-To: <CAHo-OoxNkDvuTJWfz=Q6XxS_gJyf-w_A=V_3Qi8hL_k5-18RPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 21 Nov 2011 17:52:09 -0800

> As you see, I've decided to go with the simplest 'punt the problem to
> userspace' solution.
>=20
> Hope this is acceptable...

It's a good solution, especially for 3.2-rcX

Thanks.
