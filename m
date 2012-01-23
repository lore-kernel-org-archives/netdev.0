From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] skge: add byte queue limit support
Date: Mon, 23 Jan 2012 16:48:22 +0100
Message-ID: <1327333702.2525.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120119164354.78ea63d6@nehalam.linuxnetplumber.net>
	 <1327040624.4826.10.camel@edumazet-laptop>
	 <20120122.142501.1342631979051946828.davem@davemloft.net>
	 <20120122114040.1b175e4c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:52203 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480Ab2AWPs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 10:48:26 -0500
Received: by wics10 with SMTP id s10so2219195wic.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 07:48:25 -0800 (PST)
In-Reply-To: <20120122114040.1b175e4c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 22 janvier 2012 =C3=A0 11:40 -0800, Stephen Hemminger a =C3=
=A9crit :
> This also changes the cleanup logic slightly to aggregate
> completed notifications for multiple packets.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> v2 - change location of netdev_sent_queue to avoid race

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
