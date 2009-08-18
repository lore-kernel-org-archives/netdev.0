From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert netlink ABI change to gnet_stats_basic
Date: Mon, 17 Aug 2009 21:34:45 -0700 (PDT)
Message-ID: <20090817.213445.74138658.davem@davemloft.net>
References: <118a63b80908160642j73568637n2f3fa97fc33d8e57@mail.gmail.com>
	<4A885FD1.4030105@gmail.com>
	<118a63b80908161310r69c0810fg247341f09ced8932@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mspang@csclub.uwaterloo.ca
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751202AbZHREeg@vger.kernel.org>
In-Reply-To: <118a63b80908161310r69c0810fg247341f09ced8932@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michael Spang <mspang@csclub.uwaterloo.ca>
Date: Sun, 16 Aug 2009 16:10:12 -0400

> On Sun, Aug 16, 2009 at 3:36 PM, Eric Dumazet<eric.dumazet@gmail.com>=
 wrote:
>> Michael Spang a =E9crit :
>>
>> OK, then we are stuck to use a separate definition for user land
>> and kernel land, or risk various side effects, like performance hit
>> and security risk.
>>
>> Thanks a lot Michael
>>
>> [PATCH] net: restore gnet_stats_basic to previous definition
>=20
> Applied it and it works for me, thanks.

Applied to net-2.6, thanks everyone.
