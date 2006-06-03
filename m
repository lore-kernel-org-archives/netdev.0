From: David Miller <davem@davemloft.net>
Subject: Re: The AI parameter of tcp_highspeed.c (in 2.6.18)
Date: Fri, 02 Jun 2006 17:51:40 -0700 (PDT)
Message-ID: <20060602.175140.45178680.davem@davemloft.net>
References: <7335583a0605292112l1f5a6ec3x4b1c1e4ae45688f5@mail.gmail.com>
	<20060602120507.7e1206d8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidwei79@gmail.com, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:735
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S932568AbWFCAvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 20:51:38 -0400
To: shemminger@osdl.org
In-Reply-To: <20060602120507.7e1206d8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 2 Jun 2006 12:05:07 -0700

> Went backed and looked at the RFC. The problem was just a simple
> translation of table to C array (0 based). Added this to the TCP
> testing repository.

Patch applied, thanks a lot.
