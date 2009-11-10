From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: fix incorrect counting in __scm_destroy()
Date: Tue, 10 Nov 2009 07:33:07 +0100
Message-ID: <4AF90923.7030709@gmail.com>
References: <20091104100717.4785.57149.sendpatchset@localhost.localdomain>	<4AF15771.8060204@gmail.com> <20091104.044116.37320720.davem@davemloft.net> <4AF90461.5090800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752001AbZKJGdJ@vger.kernel.org>
In-Reply-To: <4AF90461.5090800@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cong Wang a =E9crit :
>=20
> Yes, this even happens after commit f8d570a47.
>=20
> But after doing a bisect, we found another hrtimer patch fixes this
> problem, so it's not a bug of __scm_destroy().
>=20
> Sorry for the noise.
>=20

Thanks for the explanation !
