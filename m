From: Robert Olsson <robert@robur.slu.se>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 23:56:59 +0200
Message-ID: <18595.22699.600206.82767@robur.slu.se>
References: <48A23137.2010107@myri.com>
	<20080812.181549.229367205.davem@davemloft.net>
	<48A30834.4090802@myri.com>
	<18595.15208.734736.864386@robur.slu.se>
	<20080813143459.1fb1c5c5@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:33872 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbYHMV5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 17:57:00 -0400
In-Reply-To: <20080813143459.1fb1c5c5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger writes:
 > 
 > I see you are still using the SLAB allocator. Does the SLUB change the numbers?

 Correct. I did try SLUB a couple month ago but got less performance
 but there have been some SLUB patches since. Have you experimented?

 Cheers
					--ro

  
