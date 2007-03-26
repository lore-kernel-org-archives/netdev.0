From: Paul Mackerras <paulus@samba.org>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Mon, 26 Mar 2007 11:01:54 +1000
Message-ID: <17927.7042.275411.345713@cargo.ozlabs.ibm.com>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
	<Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de>
	<Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"irda-users@lists.sourceforge.net" <irda-users@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	akpm@linux-foundation.org
To: Guennadi Liakhovetski <gl@dsa-ac.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36652 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933297AbXCZBCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 21:02:31 -0400
In-Reply-To: <Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guennadi Liakhovetski writes:

> Don't leak an sk_buff on interface destruction.
> 
> Signed-off-by: G. Liakhovetski <gl@dsa-ac.de>

Acked-by: Paul Mackerras <paulus@samba.org>
