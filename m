From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: kernel driver "drivers/net/ethernet/realtek/r8169.c" msleep
 question
Date: Mon, 24 Feb 2014 00:55:53 +0100
Message-ID: <20140223235553.GA8780@electric-eye.fr.zoreil.com>
References: <20140223223840.GA29808@snape.qqa.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Justin van Wijngaarden <justinvanwijngaarden@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46699 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaBWX4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 18:56:04 -0500
Content-Disposition: inline
In-Reply-To: <20140223223840.GA29808@snape.qqa.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Justin van Wijngaarden <justinvanwijngaarden@gmail.com> :
[...]
> If you like I can take a re-write to usleep (1ms) or perhaps a 10/20 msleep.
> I tested it both with my own hardware which works fine on both cases, but
> ofcourse I don't have the hardware to test it for all use-cases.
> 
> Any preference?

There is no much gain here.

I respectfully suggest to focus on real bugs.

-- 
Ueimor
