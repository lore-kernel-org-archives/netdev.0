From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix for Refine IPv6 Address Validation Timer
Date: 28 Oct 2002 04:23:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035807835.7702.5.camel@rth.ninka.net>
References: <20021027.011025.86893867.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?=
	=?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021027.011025.86893867.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2002-10-26 at 09:10, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> We sent a patch to refine timing of IPv6 address validation timer.
> However, timer was not recalculated on receipt of RA.
> This patch fixes this bug.

I've applied this patch, thank you.
