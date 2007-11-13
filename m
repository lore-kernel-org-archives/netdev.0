From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 14:33:03 +0300
Message-ID: <20071113113303.GB14494@2ka.mipt.ru>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com> <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Natalie Protasevich <protasnb@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38740 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753604AbXKMLc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 06:32:59 -0500
Content-Disposition: inline
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 03:15:53AM -0800, Andrew Morton (akpm@linux-foundation.org) wrote:
> > NETWORKING===========================================================
> > 
> > RTNLGRP_ND_USEROPT does not report ifindex (IPv6)
> > http://bugzilla.kernel.org/show_bug.cgi?id=9349
> > Kernel: 2.6.24+
> 
> No response from developers

Fixed (extended) in the DaveM's tree (or will be soon - patch was
submitted by Pierre Ynard).

Sorry, others are either driver related (and thus require
hardware to be tested on and maintainers to be kicked in) 
or too obscure (like 2.6.11 bug and weird network problem 
which is undetectible on other systems).

Yes, we suck, but we try to recover :)

-- 
	Evgeniy Polyakov
