From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Garbage scope-id in MSG_ERRQUEUE message
Date: 28 Oct 2002 04:21:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035807684.7702.3.camel@rth.ninka.net>
References: <20021026.112813.43505001.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?=
	=?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021026.112813.43505001.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2002-10-25 at 19:28, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> This patch clears sin6_scope_id in sockaddr_in6 in MSG_ERRQUEUE
> message.  Without this we would see garbage there.

I've applied this patch, thank you.
