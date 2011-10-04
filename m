From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 04 Oct 2011 09:58:55 -0700
Message-ID: <m27h4klmls.fsf@firstfloor.org>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	<20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57913 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932341Ab1JDQ64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 12:58:56 -0400
In-Reply-To: <20111004093413.2f6bbd67@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Tue, 4 Oct 2011 09:34:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> This adds a new 'br' command which is the bridging equivalent of
> the ip command. More of a demo of how to use netlink and bridging
> at this point.

Please name it "bridge", not "br"

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
