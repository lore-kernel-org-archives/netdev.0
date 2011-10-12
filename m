From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net-netlink: Add a new attribute to expose TOS
 values via netlink
Date: Wed, 12 Oct 2011 19:10:15 -0400 (EDT)
Message-ID: <20111012.191015.389657713979036834.davem@davemloft.net>
References: <20111012085235.3b78729b@nehalam.linuxnetplumber.net>
	<1318446035-10267-1-git-send-email-muralira@google.com>
	<1318446934.2644.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: muralira@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318446934.2644.0.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 12 Oct 2011 21:15:34 +0200

> Le mercredi 12 octobre 2011 =E0 12:00 -0700, Muraliraja Muniraju a =E9=
crit :
>> From: Murali Raja <muralira@google.com>
>>=20
>> This patch exposes the tos value for the TCP sockets when the TOS fl=
ag
>> is requested in the ext_flags for the inet_diag request. This would =
mainly be
>> used to expose TOS values for both for TCP and UDP sockets. Currentl=
y it is
>> supported for TCP. When netlink support for UDP would be added the s=
upport
>> to expose the TOS values would alse be done. For IPV4 tos value is e=
xposed
>> and for IPV6 tclass value is exposed.
>>=20
>> Signed-off-by: Murali Raja <muralira@google.com>
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
