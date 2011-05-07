From: Gervais Arthur <arthur.gervais@insa-lyon.fr>
Subject: Re: Fwd: PROBLEM: IPv6 Duplicate Address Detection with non RFC-conform
 ICMPv6 packets
Date: Sat, 07 May 2011 16:35:56 +0200
Message-ID: <6fc82268416d8f6cfd40ea8b1bc4ebdf@mail.insa-lyon.fr>
References: <4DC54157.9010306@computer.org>	 <1304773802.2821.1214.camel@edumazet-laptop>	 <dc9a790de083b31ff85c0b9578c980e7@mail.insa-lyon.fr>	 <1304774758.2821.1237.camel@edumazet-laptop>	 <842648e0f4a8c6f7cd8a47cd6916a939@mail.insa-lyon.fr> <1304777182.2821.1262.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Ceuleers <jan.ceuleers@computer.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from criges14.insa-lyon.fr ([134.214.76.242]:42223 "EHLO
	smtp.insa-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab1EGOf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 10:35:57 -0400
In-Reply-To: <1304777182.2821.1262.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2011 04:06 PM, Eric Dumazet wrote:
 > Le samedi 07 mai 2011 =C3=A0 15:54 +0200, Gervais Arthur a =C3=A9cri=
t :
 >
 >> Why would the victim itself claim already having the IPv6 address?
 >>
 >
 > Why should it care ? Please point me the RFC saying its illegal to s=
end
 > or receive a frame with SRC_MAC =3D=3D DST_MAC
 >

There is no RFC statement saying that this is illegal. But we are not=20
only talking about the Ethernet layer. There is also the ICMPv6 Layer.

But neither in the IPv6 RFC's I can find something about this.

