From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.37-rc2 after KVM shutdown - unregister_netdevice: waiting
 for vmtst01eth0 to become free. Usage count = 1
Date: Thu, 18 Nov 2010 10:16:53 +0100
Message-ID: <1290071813.2781.1.camel@edumazet-laptop>
References: <20101116084148.GA3781@pcnci.linuxbox.cz>
	 <1289900812.5372.1.camel@edumazet-laptop>
	 <20101118062822.GB3781@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KVM list <kvm@vger.kernel.org>,
	netdev list <netdev@vger.kernel.org>,
	nikola.ciprich@linuxbox.cz,
	Linux kernel list <linux-kernel@vger.kernel.org>
To: Nikola Ciprich <extmaillist@linuxbox.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101118062822.GB3781@pcnci.linuxbox.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 18 novembre 2010 =C3=A0 07:28 +0100, Nikola Ciprich a =C3=A9cr=
it :
> > Yep, this is a known problem, thanks !
> >=20
> > fix is there :=20
> >=20
> > http://patchwork.ozlabs.org/patch/71354/
> Thanks Eric, this indeed fixes the problem..
> I noticed the fix didn't make it to 2.6.37-rc2-git3 though,
> maybe it just got omited?
> anyways, thanks for help!
> n.

Its in David Miller net-2.6 tree (all pending network patches for
current linux-2.6 version), so it'll be included next time David push
its tree to Linus, dont worry ;)
