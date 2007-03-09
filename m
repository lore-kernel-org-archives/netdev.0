From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 1/2] [IPV6]: Return correct result for sticky options.
Date: Thu, 8 Mar 2007 17:28:32 -0800
Message-ID: <20070309012832.GB1565@sequoia.sous-sol.org>
References: <20070309.101152.77796563.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:38063 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965073AbXCIB2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 20:28:03 -0500
Content-Disposition: inline
In-Reply-To: <20070309.101152.77796563.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E (yoshfuji@li=
nux-ipv6.org) wrote:
> We returned incorrect result with IPV6_RTHDRDSTOPTS, IPV6_RTHDR and
> IPV6_DSTOPTS.

This makes a lot more sense.  I wondered about that, thanks.
-chris
