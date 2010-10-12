From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: Remove check for ipv4_is_lbcast() that will
 always return false
Date: Tue, 12 Oct 2010 12:28:41 -0700 (PDT)
Message-ID: <20101012.122841.183039561.davem@davemloft.net>
References: <1286727021.2435.17.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net
To: awalls@md.metrocast.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46527
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751497Ab0JLT2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 15:28:22 -0400
In-Reply-To: <1286727021.2435.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Walls <awalls@md.metrocast.net>
Date: Sun, 10 Oct 2010 12:10:21 -0400

> In making an IPv4 routing decision, packets with an all 1's broadcast
> destination are accepted as input packets, before being checked for being a
> martian.  Remove the martian check for the all 1's broadcast destination
> address.  Make the initial check for the all 1's broadcast destination
> address easier to read.
> 
> Signed-off-by: Andy Walls <awalls@md.metrocast.net>

Your email client corrupted this patch, by turning tab characters
into spaces, amongst other things.

Please give Documentation/email-clients.txt a read and resubmit this
patch after you have these issues sorted out.

Thank you.
