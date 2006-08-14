From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][NET::SCHED]: cleanup qdisc_restart
Date: Mon, 14 Aug 2006 16:00:16 -0700 (PDT)
Message-ID: <20060814.160016.23014480.davem@davemloft.net>
References: <44E1DD5F.4020603@osdl.org>
	<20060814.140136.88477982.davem@davemloft.net>
	<1155596247.6946.9.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30627
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965032AbWHNXAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 19:00:17 -0400
To: hadi@cyberus.ca
In-Reply-To: <1155596247.6946.9.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 14 Aug 2006 18:57:27 -0400

> The question to ask though is: shouldnt we be having drivers use the
> mnemonics instead of values like 1? 

Absolutely, but while such conversions still remain undone
we shouldn't knowingly break stuff :)
