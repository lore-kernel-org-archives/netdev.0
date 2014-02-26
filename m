From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] AX88179_178A: Add VID:DID for Lenovo OneLinkDock
 Gigabit LAN
Date: Wed, 26 Feb 2014 14:37:31 -0800
Message-ID: <1393454251.24588.15.camel@joe-AO722>
References: <87zjle6pif.fsf@nemi.mork.no>
	 <20140226.154801.1466276966991949680.davem@davemloft.net>
	 <87lhwx7f19.fsf@nemi.mork.no>
	 <20140226.161659.2024676575146527914.davem@davemloft.net>
	 <87fvn57dn1.fsf@nemi.mork.no> <86mwhd7bt1.fsf@hiro.keithp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>, freddy@asix.com.tw,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Keith Packard <keithp@keithp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <86mwhd7bt1.fsf@hiro.keithp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-02-26 at 14:23 -0800, Keith Packard wrote:
> Bj=F8rn Mork <bjorn@mork.no> writes:
>=20
> > No, you didn't.  And when I went looking at it now, I see why: It w=
as
> > posted to linux-usb and linux-kernel but not to netdev:
> > http://www.kernelhub.org/?msg=3D420289&p=3D2
>=20
> I looked in MAINTAINERS and found linux-usb as a suitable address for
> drivers/net/usb/. I'm sorry I didn't think to look for drivers/net/ a=
s
> well.

Hi Keith.

You could use scripts/get_maintainer.pl next time.

$ ./scripts/get_maintainer.pl -f drivers/net/usb/ax88179_178a.c
"David S. Miller" <davem@davemloft.net> (commit_signer:13/13=3D100%)
=46reddy Xin <freddy@asix.com.tw> (commit_signer:4/13=3D31%,authored:4/=
13=3D31%,added_lines:1473/1504=3D98%,removed_lines:9/43=3D21%)
Eric Dumazet <edumazet@google.com> (commit_signer:3/13=3D23%,authored:2=
/13=3D15%,removed_lines:22/43=3D51%)
Ming Lei <ming.lei@canonical.com> (commit_signer:3/13=3D23%,authored:3/=
13=3D23%,removed_lines:8/43=3D19%)
David Chang <dchang@suse.com> (commit_signer:2/13=3D15%,authored:2/13=3D=
15%)
Emil Goode <emilgoode@gmail.com> (authored:1/13=3D8%)
linux-usb@vger.kernel.org (open list:USB NETWORKING DR...)
netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
linux-kernel@vger.kernel.org (open list)


Maybe there should be a MAINTAINERS entry added too?
