From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: iproute2/nstat: Bug in displaying icmp stats
Date: Fri, 5 Dec 2014 19:45:28 -0800
Message-ID: <CAGK4HS_hmmgbgNfjApa_VANnkBJKWX0PafQYDQBwcExh6wOdsw@mail.gmail.com>
References: <CAGK4HS_ty2=f0PNU-w8QPP9BoP67E+4MaDxLTLV4G22dx_7A-Q@mail.gmail.com>
	<1417828247.15618.19.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417828430.15618.20.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417831808.15618.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57143 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaLFDp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 22:45:29 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so449631wid.5
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 19:45:28 -0800 (PST)
In-Reply-To: <1417831808.15618.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Something like that maybe ?
>
>  misc/nstat.c |   18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
> diff --git a/misc/nstat.c b/misc/nstat.c

Thanks Eric!
This works on current kernel and looks good to me for 2.4 too..

Tested-by: Vijay Subramanian <subramanian.vijay@gmail.com>


Vijay
