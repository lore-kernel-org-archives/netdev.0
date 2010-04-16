From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 21:37:59 +0200
Message-ID: <1271446679.16881.4298.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:60532 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758496Ab0DPTiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 15:38:04 -0400
Received: by bwz25 with SMTP id 25so3550504bwz.28
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 12:38:02 -0700 (PDT)
In-Reply-To: <20100415.233334.242114544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 23:33 -0700, David Miller a =C3=A9crit :
> From: Tom Herbert <therbert@google.com>
> Date: Thu, 15 Apr 2010 22:47:08 -0700 (PDT)
>=20
> > Version 5 of RFS:
> > - Moved rps_sock_flow_sysctl into net/core/sysctl_net_core.c as a
> > static function.
> > - Apply limits to rps_sock_flow_entires systcl and rps_flow_count
> > sysfs variable.
>=20
> I've read this over a few times and I think it's ready to go into
> net-next-2.6, we can tweak things as-needed from here on out.
>=20
> Eric, what do you think?

I think I can give my Sob, and we have time to fully test it and tweak
it if necessary.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Tom !


