From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add a synchronize_net() in
 netdev_rx_handler_unregister()
Date: Fri, 29 Mar 2013 12:26:22 -0700
Message-ID: <1364585182.5113.58.camel@edumazet-glaptop>
References: <1364490997.6345.237.camel@gandalf.local.home>
	 <1364491792.15753.47.camel@edumazet-glaptop>
	 <20130329094856.GB1677@minipsycho.orion>
	 <1364562082.5113.16.camel@edumazet-glaptop>
	 <20130329192011.GO3320@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>, stephen@networkplumber.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:42773 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599Ab3C2T0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:26:25 -0400
In-Reply-To: <20130329192011.GO3320@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 12:20 -0700, Paul E. McKenney wrote:

> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
> With kudos to Steven Rostedt for his analogy between RCU and
> Schr=C3=B6dinger's cat.  ;-)

Thanks Paul !
