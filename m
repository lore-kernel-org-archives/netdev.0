From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sk98lin, jumbo frames, and memory fragmentation
Date: Mon, 1 Oct 2007 14:57:03 -0700
Message-ID: <20071001145703.23669471@freepuppy.rosehill>
References: <47015A24.7000701@nortel.com>
	<20071001140627.1e2e665f@freepuppy.rosehill>
	<4701638F.2020903@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux@syskonnect.de, netdev@vger.kernel.org
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35453 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751447AbXJAV5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 17:57:21 -0400
In-Reply-To: <4701638F.2020903@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 01 Oct 2007 15:15:59 -0600
"Chris Friesen" <cfriesen@nortel.com> wrote:

> Stephen Hemminger wrote:
> 
> > Adding fragmentation support to skge driver is on my list of
> > possible extensions. sky2 driver already supports it (yet one
> > more feature that the vendor sk98lin driver doesn't do).
> 
> Thanks for speaking up.  As I mentioned in my email to Jeff it looks 
> like the sky2 driver is what I need (Marvel Yukon 88E8062).  However, 
> I'm on 2.6.14 and it doesn't exist there...do you anticipate any issues 
> if I were to backport it?

Nothing but usual annoying kernel API changes..


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
