From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6 0/8] mostly bonding rx path changes
Date: Sat, 05 Mar 2011 10:12:09 +0100
Message-ID: <1299316329.2758.75.camel@edumazet-laptop>
References: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52134 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab1CEJMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 04:12:15 -0500
Received: by bwz15 with SMTP id 15so2675723bwz.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 01:12:14 -0800 (PST)
In-Reply-To: <1299313794-5218-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 05 mars 2011 =C3=A0 09:29 +0100, Jiri Pirko a =C3=A9crit :
> This patchset focuses mainly bonding rx path changes.
>=20
> Depends on "fcoe: correct checking for bonding"
>=20
> Jiri Pirko (8):
>   af_packet: use skb->skb_iif instead of orig_dev->ifindex
>   bonding: register slave pointer for rx_handler
>   net: get rid of multiple bond-related netdevice->priv_flags
>   bonding: wrap slave state work
>   bonding: get rid of IFF_SLAVE_INACTIVE netdev->priv_flag
>   bonding: move processing of recv handlers into handle_frame()
>   net: introduce rx_handler results and logic around that
>   net: get rid of orig_dev parameter of packet handlers
>=20

Jiri, I do believe your changelogs are not very helpful ...

Oh wait, maybe you forgot to _include_ them ?

;)


