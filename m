From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Bug#572201: forcedeth driver hangs under heavy load
Date: Mon, 12 Apr 2010 14:47:06 +0200
Message-ID: <1271076426.16881.21.camel@edumazet-laptop>
References: <4B9E6C60.7030300@atlanticlinux.ie>
	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>
		 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>
	 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>
	  <4BC31486.1090603@gmail.com>
Reply-To: Eric Dumazet <eric.dumazet@gmail.com>, 572201@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>,  Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: stephen mulcahy <smulcahy@gmail.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.572201.B572201.127107644132279@bugs.debian.org>
In-Reply-To: <4BC31486.1090603@gmail.com>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Le lundi 12 avril 2010 =C3=A0 13:39 +0100, stephen mulcahy a =C3=A9crit :
> stephen mulcahy wrote:
> > It doesn't - further testing over the weekend saw 6 of 45 machines dr=
op=20
> > off the network with this problem. Nothing in dmesg or system logs.=20
> > Happy to run more tests if someone can advise on what should be run.
>=20
> I also just tried using the 2.6.30-2-amd64 (Debian) forcedeth kernel=20
> module while running the 2.6.32-3-amd64 (Debian) kernel and experienced=
=20
> the same symptoms.
>=20
> Not sure if thats any help.
>=20

I am not sure I understand. Are you saying that using 2.6.30-2-amd64
kernel also makes your forcedeth adapter being not functional ?

Are both way non functional (RX and TX), or only one side ?






--=20
To UNSUBSCRIBE, email to debian-bugs-dist-REQUEST@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian=
.org
