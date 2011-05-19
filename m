From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4] rps: Some minor cleanup in get_rps_cpus
Date: Thu, 19 May 2011 22:21:04 +0200
Message-ID: <1305836464.3156.17.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1105190827480.12796@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61115 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933926Ab1ESUVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:21:08 -0400
Received: by wwa36 with SMTP id 36so3287253wwa.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 13:21:07 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105190827480.12796@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 08:39 -0700, Tom Herbert a =C3=A9crit :
> Use some variables for clarity and extensibility.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c |   12 +++++++-----
>  1 files changed, 7 insertions(+), 5 deletions(-)

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


