From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] phonet: fix build when PROC_FS is disabled
Date: Mon, 17 Aug 2009 17:49:19 -0700 (PDT)
Message-ID: <20090817.174919.265251863.davem@davemloft.net>
References: <4A89BF25.9010404@oracle.com>
	<200908172343.44744.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: randy.dunlap@oracle.com, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: remi@remlab.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <200908172343.44744.remi@remlab.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Mon, 17 Aug 2009 23:43:43 +0300

> Le lundi 17 ao=FBt 2009 23:35:49 Randy Dunlap, vous avez =E9crit :
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> Fix phonet build when PROC_FS is not enabled:
>>
>> net/built-in.o: In function `pn_sock_open':
>> socket.c:(.text+0x23c649): undefined reference to `seq_open_net'
>> net/built-in.o:(.rodata+0x21018): undefined reference to `seq_releas=
e_net'
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>=20
> Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks.
