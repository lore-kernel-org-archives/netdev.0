From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: sk98lin, jumbo frames, and memory fragmentation
Date: Mon, 01 Oct 2007 15:15:59 -0600
Message-ID: <4701638F.2020903@nortel.com>
References: <47015A24.7000701@nortel.com> <20071001140627.1e2e665f@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@syskonnect.de, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:59066 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbXJAVQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 17:16:20 -0400
In-Reply-To: <20071001140627.1e2e665f@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Adding fragmentation support to skge driver is on my list of
> possible extensions. sky2 driver already supports it (yet one
> more feature that the vendor sk98lin driver doesn't do).

Thanks for speaking up.  As I mentioned in my email to Jeff it looks 
like the sky2 driver is what I need (Marvel Yukon 88E8062).  However, 
I'm on 2.6.14 and it doesn't exist there...do you anticipate any issues 
if I were to backport it?

Thanks,

Chris
