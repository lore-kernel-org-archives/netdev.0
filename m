From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: ping when network down BUG: unable to handle kernel NULL pointer
 dereference at 000000000000001b
Date: Wed, 30 Mar 2011 10:13:58 +0800
Message-ID: <AANLkTinxKri8QEfcnBCBg7Pxh-8fk9Yf3VVVdH76_YXe@mail.gmail.com>
References: <AANLkTinthHDRYpfNrXSiOz9t_y5HyVMpjP-dLm_bn0es@mail.gmail.com>
	<1301410764.3161.156.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301410764.3161.156.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2011 at 10:59 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 29 mars 2011 =E0 22:54 +0800, Jeff Chua a =E9crit :
>> I don't know when this started happening as my network was always up=
=2E
>> Just down, I shutdown my network, and ping a known host and
>> encountered this BUG.
> Known problem, should be fixed by
 http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcom=
mit;h=3D4910ac6c526d2868adcb5893e0c428473de862b5

Cool. I just git pulled the commit, and it works now!

Thanks,
Jeff
