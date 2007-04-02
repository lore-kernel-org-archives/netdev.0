From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Mon, 02 Apr 2007 16:20:00 -0400
Message-ID: <46116570.3050109@redhat.com>
References: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de
To: Christian Kujau <evil@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36428 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965822AbXDBUUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 16:20:04 -0400
In-Reply-To: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Kujau wrote:
> 
> Please see http://nerdbynature.de/bits/2.6.20.4/ for details for both
> hosts and feel free to ask for more details. Although both boxes are in
> production we'll be happy test more bootoptions/patches and the like.

Where is the info from before you changed to "noapic"? Or were the
machines always using XT-PIC for all the interrupts???

