From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: 2.6.7 oops, sk98lin related?
Date: Thu, 22 Jul 2004 19:08:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200407221908.41468.bernd-schubert@web.de>
References: <200407221101.16388.bernd-schubert@web.de> <20040722150314.GB13195@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265215AbUGVRJB@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <20040722150314.GB13195@infradead.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

> > is this an sk98lin oops, maybe related to your patches or is it a
> > completely different problem?
>
> I don't think there's skge patches from me in 2.6.7 yet, but certainl=
y not
> in that area ;-)

Well just remember, on 20040704 you send me a 'huge patch' which should=
 also=20
fix our module unload problems.

>
> This is just a big memory allocation failing, not an oops anyway.

Unfortunality I began to capture via serial console only a few hour aft=
er the=20
server crashed. As there is also nothing in the logs, I don't have the=20
beginning trace of the problems.

Since there is something about sk98 in almost all traces, I thought it =
might=20
be a sk98lin problem.

Anyway, do you have an idea what might have cause this memory allocatio=
n=20
problem?


Thanks,
	Bernd


--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
