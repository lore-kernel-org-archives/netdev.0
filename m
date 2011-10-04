From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 4 Oct 2011 14:07:54 -0700
Message-ID: <20111004140754.0e677941@nehalam.linuxnetplumber.net>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	<20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
	<m27h4klmls.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56361 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933618Ab1JDVIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 17:08:01 -0400
In-Reply-To: <m27h4klmls.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Oct 2011 09:58:55 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
> > This adds a new 'br' command which is the bridging equivalent of
> > the ip command. More of a demo of how to use netlink and bridging
> > at this point.
> 
> Please name it "bridge", not "br"
> 
> -Andi

Ok, but it breaks the existing pattern.
