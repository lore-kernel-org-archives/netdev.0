From: Robert Olsson <robert@robur.slu.se>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Thu, 14 Aug 2008 00:21:45 +0200
Message-ID: <18595.24185.248507.604291@robur.slu.se>
References: <48A23137.2010107@myri.com>
	<20080812.181549.229367205.davem@davemloft.net>
	<48A30834.4090802@myri.com>
	<18595.15208.734736.864386@robur.slu.se>
	<20080813143459.1fb1c5c5@extreme>
	<18595.22699.600206.82767@robur.slu.se>
	<20080813150625.30405c5f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:44217 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753331AbYHMWVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 18:21:46 -0400
In-Reply-To: <20080813150625.30405c5f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



 > Not yet, but there was a movement to kill SLAB. If SLAB is still faster than
 > Christoph probably wants to know (and fix the problem).  The problem is that
 > one way flows might still be moving memory between CPU's

 How does this happen? (Assuming affinity is setup correct of course)

 Cheers
					--ro
