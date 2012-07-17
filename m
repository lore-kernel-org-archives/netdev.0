From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix incorrect route 'expires' value passed to userspace.
Date: Tue, 17 Jul 2012 09:55:31 +0800
Message-ID: <5004C613.5030208@cn.fujitsu.com>
References: <5003CC41.9080204@cn.fujitsu.com> <20120716.025649.1070277404591664104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:39444 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab2GQB4P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 21:56:15 -0400
In-Reply-To: <20120716.025649.1070277404591664104.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012-7-16 17:56, David Miller =E5=86=99=E9=81=93:
>=20
> Without a proper signoff, I won't apply your patch.
>=20
>=20

Sorry for that, I will append a signoff, do some code refactor
and send a V2.

Thanks,
Wei
