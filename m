From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: ndisc_rcv() clean-up
Date: 28 Oct 2002 04:18:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035807506.7701.1.camel@rth.ninka.net>
References: <20021025.094459.116783443.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?=
	=?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021025.094459.116783443.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2002-10-24 at 17:44, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> This patch just adds new ndisc_recv_ns() and ndisc_recv_na() to
> make switch / case in ndisc_rcv() (and ndisc_rcv() itself) small.

I've applied this patch.  Thank you.

Can I ask that you CC: me and Alexey directly on future USAGI
patches?  That helps me work more efficiently.  Thank you.
