From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Tue, 22 Nov 2011 10:27:09 +0100
Message-ID: <1321954029.2474.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111121161036.GA1679@x4.trippels.de>
	 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121173556.GA1673@x4.trippels.de>
	 <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121185215.GA1673@x4.trippels.de>
	 <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop>
	 <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
	 <alpine.DEB.2.00.1111212105330.19606@router.home>
	 <20111122084513.GA1688@x4.trippels.de>
	 <1321953911.2474.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Christoph Lameter <cl@linux.com>, Christian Kujau
 <lists@nerdbynature.de>,  Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,  Pekka Enberg
 <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1321953911.2474.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 22 novembre 2011 =C3=A0 10:25 +0100, Eric Dumazet a =C3=A9crit :

> One thing you could do is to disable slub merge, with following
> additional boot param : "slub_nomerge=3D1"
>=20
>=20

Oh well, this is the default with debug options, sorry.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
