From: P@draigBrady.com
Subject: Re: Device naming for wireless NICs...
Date: Fri, 12 Mar 2004 10:30:49 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40519159.8000104@draigBrady.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com> <20040311024816.GC3738@jm.kir.nu> <404FD6BC.7090409@pobox.com> <20040311031709.GC3782@jm.kir.nu> <405093A7.90209@linux.co.intel.com> <4050AE90.9070005@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4050AE90.9070005@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> James Ketrenos wrote:
>=20
> Like Matthew said, any code that assumes a specific interface prefix, b=
e=20
> it eth%d or wlan%d, is buggy.  Users are allowed to choose random=20
> interface names for their interfaces, often via nameif(8) program.  My=20
> own ethtool program is broken in this regard...

My trivial patch fixes that.
http://sourceforge.net/tracker/index.php?func=3Ddetail&aid=3D780937&group=
_id=3D3242&atid=3D303242

Just wondering about the release schedule for ethtool?

P=E1draig.
