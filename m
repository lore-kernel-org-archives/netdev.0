From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tg3: Remove prev_vlan_tag from struct tx_ring_info
Date: Fri, 02 Oct 2009 06:16:48 +0200
Message-ID: <4AC57EB0.3050602@gmail.com>
References: <4AC36638.8070304@gmail.com>	<20090930172643.GA14439@xw6200.broadcom.net> <20091001.143859.53379358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46952 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbZJBEQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 00:16:50 -0400
In-Reply-To: <20091001.143859.53379358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> Applied, thanks.
>=20
> Eric, I had to apply this by hand because:
>=20
>>> @@ -2412,7 +2412,6 @@ struct ring_info {
>>> =20
>>>  struct tx_ring_info {
>>>  	struct sk_buff                  *skb;
>>> -	u32                             prev_vlan_tag;
>>>  };
>=20
> Your email client changed tabs into spaces.

Oops, I'm sorry Dave, I did a copy/paste and forgot about tabs.

Thanks
