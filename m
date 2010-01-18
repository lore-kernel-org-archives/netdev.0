From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: atl1e: TSO is broken
Date: Mon, 18 Jan 2010 13:42:43 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A49508C6376@SHEXMB-01.global.atheros.com>
References: <20100115.135613.1130385479658158300.anders@netinsight.net>
 <20100115165447.2eb7d547@varda>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xiong Huang <Xiong.Huang@Atheros.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Alejandro_Riveira_Fern=E1ndez?= <ariveira@gmail.com>,
	=?iso-8859-1?Q?Anders_Bostr=F6m?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:43021 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750751Ab0ARFsL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 00:48:11 -0500
In-Reply-To: <20100115165447.2eb7d547@varda>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 15, 2010 11:55 PM
Alejandro Riveira Fern=E1ndez <ariveira@gmail.com> wrote:
> > Short desription
> > ----------------
> >
> > TCP Segmentation Offload (TSO) result in broken
> IPv4-packets sent out
> > from Atheros AR8121/AR8113/AR8114 with the atl1e driver.
> >
> >
> > Work around
> > -----------
> >
> > Turn off TSO. Requires 2.6.33-rc1 or later.
> >
> >

Ok, I will try to reproduce it first.

Best wishes
jie
