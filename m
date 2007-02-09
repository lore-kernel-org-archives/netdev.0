From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [NET]: Fix whitespace errors
Date: Fri, 9 Feb 2007 09:47:27 -0600
Message-ID: <F29DCCE2-0FF6-4B9A-BA07-2D812BF4B320@kernel.crashing.org>
References: <20070209.234154.22788645.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=UTF-8;
	delsp=yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
To: =?UTF-8?Q?YOSHIFUJI_Hideaki_/_=E5=90=89=E8=97=A4=E8=8B=B1?=
	 =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:40756 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946538AbXBIPsP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 10:48:15 -0500
In-Reply-To: <20070209.234154.22788645.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 9, 2007, at 8:41 AM, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:

> Hello.
>
> Please pull "2.6.20-net-2.6-20070209-whitespace" branch
> at <git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
> to fix trivial whitespace errors:
>  - convert leading sequences of whitespace with tab(s).
>  - remove whitespace at the end of line.
> under net.
>
> Tree is on top of current net-2.6 tree.

Do you have a script that did this?

And is this type of cleanup something that is desired?  I noticed a =20
asm/powerpc header that had whitespace issues and was going to commit =20
a patch, but figured I should than cleanup all the headers.  I wasn't =20
sure if cleaning up whitespace issues wholesale like this was =20
desirable or not.

- k