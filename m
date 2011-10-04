From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 04 Oct 2011 17:58:10 +0100
Message-ID: <1317747490.2751.4.camel@bwh-desktop>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	 <20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32166 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932341Ab1JDQ6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 12:58:13 -0400
In-Reply-To: <20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-04 at 09:34 -0700, Stephen Hemminger wrote:
> This adds a new 'br' command which is the bridging equivalent of
> the ip command. More of a demo of how to use netlink and bridging
> at this point.
[...]

This command name is already in use:
http://packages.debian.org/sid/bottlerocket

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
