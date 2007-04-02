From: Christian Kujau <christian@g-house.de>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Mon, 2 Apr 2007 22:15:27 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0704022212490.3963@sheep.housecafe.de>
References: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
 <46116570.3050109@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:55116 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965992AbXDBWHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 18:07:07 -0400
In-Reply-To: <46116570.3050109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Apr 2007, Chuck Ebbert wrote:
>> Please see http://nerdbynature.de/bits/2.6.20.4/ for details for both
>> hosts and feel free to ask for more details. Although both boxes are in
>> production we'll be happy test more bootoptions/patches and the like.
>
> Where is the info from before you changed to "noapic"? Or were the
> machines always using XT-PIC for all the interrupts???

Who, didn't notice the XT-PIC in /proc/interrupts. From the count of 
your questionmarks I figure it's a bad thing then?

@Malte, do we still have this information around?

Thanks,
Christian.
-- 
BOFH excuse #63:

not properly grounded, please bury computer
