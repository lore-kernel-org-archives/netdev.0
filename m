From: Philip Prindeville <philipp@redfish-solutions.com>
Subject: Re: [Announce] LARTC wiki available
Date: Sun, 03 Jun 2012 14:05:20 -0600
Message-ID: <4FCBC380.8050704@redfish-solutions.com>
References: <4EFB3B2B.7060200@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lartc@vger.kernel.org,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4EFB3B2B.7060200@linuxsystems.it>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/28/11 8:52 AM, Niccol=F2 Belli wrote:
> Hi,
> I still didn't find a viable solution for the LARTC wiki, so I decide=
d=20
> to start hosting it on my own server. Later we can easily switch=20
> somewhere else if we keep using the same wiki engine (and maybe even=20
> with another wiki engine).
> I decided to use wikimedia because it's the only one I know of, so if=
=20
> someone knows a better alternative please let me know, we are still i=
n=20
> time for a change.
> Since I never used a wiki seriously I will probably need someone else=
=20
> who can help me maintaining it, please let me know if you are=20
> experienced and willing to help.
>=20
> Here is the wiki: http://lartc.linuxsystems.it/
> And here is the new mailing list for those who still don't know:=20
> http://vger.kernel.org/vger-lists.html#lartc
>=20
> I just copy-pasted the Linux Advanced Routing & Traffic Control HOWTO=
=20
> atm, it still needs to be wikified and we still need to choose how to=
=20
> organize the contents.
>=20
> Cheers,
> Niccol=F2

Between command-line stuff for users/administrators and the kernel hack=
ing bits on linux-net, etc. I'd like to see a middle ground: i.e. bette=
r documentation about the C API to userspace from the kernel routing me=
chanisms.

Better documentation about rtnetlink would be appreciated, and maybe th=
e low-level libraries that run atop that as well, such as libmnl.

-Philip
