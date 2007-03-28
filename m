From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: reverting handle_bridge() change from net-2.6.22
Date: Tue, 27 Mar 2007 20:35:52 -0700
Message-ID: <4609E298.4040600@osdl.org>
References: <20070327.193809.74746967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52189 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666AbXC1DgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 23:36:04 -0400
In-Reply-To: <20070327.193809.74746967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> It doesn't build with bridging disabled, and I can't see
> exactly how to work out the 'ret' assignment in the way
> the new code works so I'm reverting.
>
> Please resubmit a version that builds and works properly
> with bridging enabled and disabled, thanks :-)
>   
okay, i'll fix it when back from vacation.
I have more bridge patches queued as well.
