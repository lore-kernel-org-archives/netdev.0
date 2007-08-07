From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFT] sky2: backport patch
Date: Tue, 07 Aug 2007 17:33:51 -0400
Message-ID: <46B8E53F.70605@garzik.org>
References: <Pine.LNX.4.64.0708072043340.16599@bizon.gios.gov.pl>	<20070807185631.GA19140@kroah.com> <20070807171415.6892a070@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Krzysztof Oledzki <olel@ans.pl>,
	netdev@vger.kernel.org, stable@kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60841 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937489AbXHGVeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 17:34:00 -0400
In-Reply-To: <20070807171415.6892a070@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Any volunteers to test this, it has a backport for the three main stability patches:
>  1. carrier management
>  2. lost irq timer
>  3. rechecking for packets in poll
>  4. overlength packet hang.
> 
> I am away from any sky2 hardware for another week, but others maybe
> able to validate this.

Backport to what?  from what?

You supplied no kernel version info.

	Jeff



