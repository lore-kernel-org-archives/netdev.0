From: Thomas Svedberg <Thomas.Svedberg@me.chalmers.se>
Subject: Re: Hard lock with recent 2.6.0-test kernels
Date: Fri, 17 Oct 2003 11:12:26 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1066310622.1483.2.camel@thsvlap.swenox.net>
References: <1063272933.26472.16.camel@ampc545.am.chalmers.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>,
	jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Thomas Svedberg <thsv@am.chalmers.se>
In-Reply-To: <1063272933.26472.16.camel@ampc545.am.chalmers.se>
List-Id: netdev.vger.kernel.org

I have tried a lot more of the recent kernels, and still have these
lockups.
The box is, however, completely stable if i switch from running 8139cp
to 8139too.
I am willing to test patches.

tor 2003-09-11 klockan 11.35 skrev Thomas Svedberg:
> I first experienced total lockup with 2.6.0-test4-mm5 and have now tr=
ied
> a few different ones. -test4-mm4 works, test4-bk2 works, test4-mm5
> locks, test4-bk3 locks, test5-mm1 locks.
> Nothing shows in the logs, and the lock occurs while doing random thi=
ngs
> but only after a few seconds - minutes after i logged in to X.
> sysrq don't work either.
> It is an Compaq Evo 1020v and configs etc. can be found at:
> http://www.am.chalmers.se/~thsv/laptop/ =20
--=20
/ Thomas
=2E....................................................................=
=2E.
 Thomas Svedberg
 Department of Applied Mechanics=20
 Chalmers University of Technology=20

 Address: SE-412 96 G=F6teborg, SWEDEN=20
 E-mail : thsv@am.chalmers.se, thsv@bigfoot.com
 Phone  : +46 31 772 1522
 Fax    : +46 31 772 3827
=2E....................................................................=
=2E.
