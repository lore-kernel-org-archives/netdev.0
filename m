From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 2/8] qlcnic: fix eswitch stats
Date: Mon, 11 Apr 2011 15:55:17 -0700 (PDT)
Message-ID: <20110411.155517.200362844.davem@davemloft.net>
References: <1286205297-23214-1-git-send-email-amit.salecha@qlogic.com>
	<1286205297-23214-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42912
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751609Ab1DKWzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 18:55:53 -0400
In-Reply-To: <1286205297-23214-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon,  4 Oct 2010 08:14:51 -0700

> Some of the counters are not implemented in fw.
> Fw return NOT AVAILABLE VALUE as (0xffffffffffffffff).
> Adding these counters, result in invalid value.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Why are patches being posted from back in October 4, 2010?
