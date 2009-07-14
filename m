From: David Miller <davem@davemloft.net>
Subject: Re: [TCP_CA_CWR] Causes for entering TCP_CA_CWR state with 0
 retransmissions
Date: Tue, 14 Jul 2009 12:53:41 -0700 (PDT)
Message-ID: <20090714.125341.104344345.davem@davemloft.net>
References: <46bf9ede0907141212x7a7a84f8l1882ffefbaf21e14@mail.gmail.com>
	<20090714.121528.15246520.davem@davemloft.net>
	<46bf9ede0907141249x7823c199uf3867b4d8284eb1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yinglinsun@cs.pitt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752466AbZGNTxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:53:37 -0400
In-Reply-To: <46bf9ede0907141249x7823c199uf3867b4d8284eb1c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinglin Sun <yinglinsun@cs.pitt.edu>
Date: Tue, 14 Jul 2009 15:49:52 -0400

> Do you have any idea about other invocation to tecp_enter_cwr?

I really think I've helped you as much as I could as this
point, you can read the code as easily as I could and that's
all that I would do to answer your question.  I haven't
memorized this stuff nor do I remember things like "all the
code patchs that invoke function X"

