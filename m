From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [RFC/PATCH] ICMPv6 MIB stats per-interface
Date: Tue, 15 Apr 2003 11:12:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030415111236.6e7e8ca2.rddunlap@osdl.org>
References: <20030414095030.50ad9652.rddunlap@osdl.org>
	<20030415.021728.70559400.yoshfuji@linux-ipv6.org>
	<20030415093442.0913486d.rddunlap@osdl.org>
	<20030416.030710.19512552.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?Q?=B5=C8=C6=A3=B1=D1=CC=C0?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030416.030710.19512552.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Apr 2003 03:07:10 +0900 (JST) YOSHIFUJI Hideaki / =B5=C8=C6=A3=
=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> wrote:

| In article <20030415093442.0913486d.rddunlap@osdl.org> (at Tue, 15 Apr =
2003 09:34:42 -0700), "Randy.Dunlap" <rddunlap@osdl.org> says:
|=20
| > Do you have any updates (recommendations) on how to proceed on this?
| > Have you looked at my patch file?
|=20
| Yes.  I looked at the patch.
| I also learned about seqfile.
| Now I'm typing procfs seqfile part.
| I'll send you my (uncompleted) patch.

I can help with seq_file if you need it.

| I think per-cpu * per-interface.
| and, I believe statictics should be held in inet6_dev{}.
| We need ipv6 part, too.  Would you work on this?
| (I don't have enough time to complete this in April...)

Yes, I'll begin on IPv6 statistics.

| > I think that we can make some progress without having an answer to
| > your question about /proc/sys/net/ipv6/conf/foobar file renaming.
|=20
| Sure.


--
~Randy
