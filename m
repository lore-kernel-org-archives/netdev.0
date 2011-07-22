From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/1] netxen: add fw version compatibility check
Date: Thu, 21 Jul 2011 21:33:12 -0700 (PDT)
Message-ID: <20110721.213312.792042323157822901.davem@davemloft.net>
References: <1311156533-24014-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab1GVEdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 00:33:16 -0400
In-Reply-To: <1311156533-24014-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <amit.salecha@qlogic.com>
Date: Wed, 20 Jul 2011 03:08:53 -0700

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> o Minimum fw version supported for P3 chip is 4.0.505
> o File Fw > 4.0.554 is not supported if flash fw < 4.0.554.
> o In mn firmware case, file fw older than flash fw is allowed.
> o Change variable names for readability
> o Update driver version 4.0.76
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
