From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] MAINTAINERS: add myself as Renesas Ethernet drivers
 reviewer
Date: Fri, 04 Dec 2015 17:18:36 -0800
Message-ID: <1449278316.8611.30.camel@perches.com>
References: <1846877.jRW8849mPU@wasted.cogentembedded.com>
	 <1449276063.8611.25.camel@perches.com>
	 <56623680.4050808@cogentembedded.com>
	 <1449277327.8611.27.camel@perches.com>
	 <56623A25.3040002@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56623A25.3040002@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-12-05 at 04:13 +0300, Sergei Shtylyov wrote:
> On 12/05/2015 04:02 AM, Joe Perches wrote:
> > > Since you seem to be get_maintainers.pl maintainer, I (and not on=
ly I)
> > > would like to propose a switch to suppress the committers/authors=
/etc. It's
> > > generally annoying and unhelpful to have the bunch of people list=
ed, none of
> > > which usually are a good addressees for the patches...
> >=20
> > Done!
>=20
> > Add "--nogit" and "--nogit-fallback"
>=20
> =A0=A0=A0=A0Em, --nogit is the dafault, according to --help. --nogit-=
fallback is=A0
> enough but it's undocumented. :-/

umm

$ ./scripts/get_maintainer.pl --help
[...]
=A0 =A0 --git-fallback =3D> use git when no exact MAINTAINERS pattern (=
default: 1)
[...]
=A0 Most options have both positive and negative forms.
=A0=A0=A0=A0=A0=A0The negative forms for --<foo> are --no<foo> and --no=
-<foo>.
