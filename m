From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Fix space-after-if checkpatch errors
Date: Tue, 22 Jan 2013 21:15:47 +0000
Message-ID: <1358889347.2892.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <1358888690-3140-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53653 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab3AVVPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 16:15:50 -0500
In-Reply-To: <1358888690-3140-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 21:04 +0000, Mark Einon wrote:
> Some version check statements are lacking a space after the if ()
> statement. Add them in.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
[...]

OK, I've applied this on top of your earlier patch.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
