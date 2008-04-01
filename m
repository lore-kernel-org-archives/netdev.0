From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPROUTE2 PATCH 1/2]: Add more aliases for tunnel subcommand.
Date: Tue, 1 Apr 2008 12:22:58 -0700
Message-ID: <20080401122258.592f035f@extreme>
References: <20080313.111754.126763958.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43507 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756131AbYDATXS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 15:23:18 -0400
In-Reply-To: <20080313.111754.126763958.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Mar 2008 11:17:54 -0400 (EDT)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E  <yoshfuji@lin=
ux-ipv6.org> wrote:

> Add more aliases to synchronize IPv4 and IPv6 tunnel command, e.g.,
>   IPv4: hoplimit (alias to ttl), tclass (alias to tos)
>   IPv6: dsfield, tos (alias to tc, or tclass), ttl (alias to hoplimit=
)
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20

applied to git for 2.6.25
