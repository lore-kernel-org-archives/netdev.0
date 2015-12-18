From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Random packet loss using IPsec with AES128-SHA1
Date: Fri, 18 Dec 2015 08:41:45 +0100
Message-ID: <20151218074145.GS29565@gauss.secunet.com>
References: <000a01d137e2$afedd130$0fc97390$@drvsource.net>
 <20151216095954.GN29565@gauss.secunet.com>
 <005901d138e0$a6a7a750$f3f6f5f0$@drvsource.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Gabriele Beltrame <belgab@drvsource.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47154 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375AbbLRHlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 02:41:49 -0500
Content-Disposition: inline
In-Reply-To: <005901d138e0$a6a7a750$f3f6f5f0$@drvsource.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 04:36:06PM +0100, Gabriele Beltrame wrote:
> Hi Steffen,
> 
> I don't think it's IPsec (I can see the outbound packet in tcpdump), not
> alone at least but the XEN /AWS Ethernet driver (or multiple things
> concurring to the issue) actually.i

Well, in this case you should change the subject to something that
attracts the related driver developers and resend the mail.
