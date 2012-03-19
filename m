From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qmi_wwan: fix build error due to cdc-wdm dependecy
Date: Mon, 19 Mar 2012 18:17:29 -0400 (EDT)
Message-ID: <20120319.181729.1955474261915960216.davem@davemloft.net>
References: <20120319184830.fce597a16eaf7206195a7a45@canb.auug.org.au>
	<1332179309-4163-1-git-send-email-bjorn@mork.no>
	<4F679437.8030201@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, gregkh@linuxfoundation.org
To: rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F679437.8030201@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Randy Dunlap <rdunlap@xenotime.net>
Date: Mon, 19 Mar 2012 13:16:55 -0700

> On 03/19/2012 10:48 AM, Bj=F8rn Mork wrote:
>=20
>> Fixes:
>>=20
>> drivers/built-in.o: In function `qmi_wwan_bind_shared':
>> qmi_wwan.c:(.text+0x25b686): undefined reference to `usb_cdc_wdm_reg=
ister'
>> make[1]: *** [.tmp_vmlinux1] Error 1
>>=20
>> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
>> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
>=20
>=20
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Applied.
