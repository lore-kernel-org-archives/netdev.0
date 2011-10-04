From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 4 Oct 2011 14:08:22 -0700
Message-ID: <20111004140822.56d7878b@nehalam.linuxnetplumber.net>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	<20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
	<1317747490.2751.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56402 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933618Ab1JDVIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 17:08:24 -0400
In-Reply-To: <1317747490.2751.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Oct 2011 17:58:10 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2011-10-04 at 09:34 -0700, Stephen Hemminger wrote:
> > This adds a new 'br' command which is the bridging equivalent of
> > the ip command. More of a demo of how to use netlink and bridging
> > at this point.
> [...]
> 
> This command name is already in use:
> http://packages.debian.org/sid/bottlerocket

Damn name squatters.
