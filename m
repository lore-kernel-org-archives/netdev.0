From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: [PATCH 2.6.8-rc3-mm1 1/2] 8139too: Rx fifo/overflow recovery
Date: Sat, 14 Aug 2004 21:58:14 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408142153540.23772-100000@silmu.st.jyu.fi>
References: <20040812202853.GA22774@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Hector Martin <hector@marcansoft.com>,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040812202853.GA22774@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Aug 2004, Francois Romieu wrote:

> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> > Both branches is fine.
> > You'll quickly hit the RX-error-requiring-reset condition if you don'=
t=20
> > update on each packet, though.
> M. Sjoholm, can you apply the attached patch below to a vanilla 2.6.8-r=
c4
> and report if the former bug reappears ?

Hello Francois,=20

I only tested 8139too-10.patch against vanilla 2.6.8.1 and it seems
that the 8139too-driver is working ok. I tested it for three hours=20
but I guess it's enough. =3D)=20

--
Pasi Sj=F6holm
