From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] ethtool: Add register dump support for all r8169
	driver cards
Date: Wed, 26 Mar 2008 23:11:47 +0100
Message-ID: <20080326221147.GB9034@electric-eye.fr.zoreil.com>
References: <76366b180803260519t7c446210n62d4c91209c5e971@mail.gmail.com> <20080326214432.GA9356@electric-eye.fr.zoreil.com> <76366b180803261511x518e4475n72dbcee2d1942be3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54965 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752978AbYCZWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 18:30:01 -0400
Content-Disposition: inline
In-Reply-To: <76366b180803261511x518e4475n72dbcee2d1942be3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Paprocki <andrew@ishiboo.com> :
[...]
> I'll update this shortly and re-send again. Do you have 8168 docs
> showing the differences between it and the 8169 ?

edward_hsu@realtek.com.tw may help.

> I peeked at this code because I'm trying to track down a 8110SC
> problem where the network hangs (sender hangs on sk_stream_wait_memory).
> Any useful docs on these chips would help.

I am not sure that the 8110/8169 documentation will be of much help but
you can still give it a try.

Can you elaborate on the kind of hang ? Which kernel do you use ?

-- 
Ueimor
