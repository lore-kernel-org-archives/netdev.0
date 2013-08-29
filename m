From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] realtek: update devices to 3.11
Date: Thu, 29 Aug 2013 21:52:06 +0100
Message-ID: <1377809526.5372.18.camel@bwh-desktop.uk.level5networks.com>
References: <1376429119-31380-1-git-send-email-lekensteyn@gmail.com>
	 <1376429119-31380-3-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Francois Romieu <romieu@fr.zoreil.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30955 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756534Ab3H2UwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:52:09 -0400
In-Reply-To: <1376429119-31380-3-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-13 at 23:25 +0200, Peter Wu wrote:
> RTL8168_8111Bb/RTL8168_8111Bef is like RTL8111B/RTL8168B, RTL8100E and RTL8101E
> (datasheet revision 1.0 from 26 January 2006). Assume that RTL8101e is also
> similar (I may be very wrong at that though...).
> 
> Note that the scanning heuristics is the same as the r8169 module: newer devices
> with stronger masks come before the others. Perhaps the older 8139 cards should
> be appended to the list, after all r8169 chips.
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>
[...]

Applied, thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
