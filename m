From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] RESEND 8390: Split 8390 support into a pausing and a
 non pausing driver core
Date: Wed, 16 Apr 2008 18:05:20 -0700
Message-ID: <20080416180520.2a56b77e.akpm@linux-foundation.org>
References: <20080119155817.326ee5e0@lxorguk.ukuu.org.uk>
	<48069DE1.7080301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60290 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbYDQBGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 21:06:06 -0400
In-Reply-To: <48069DE1.7080301@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Apr 2008 20:46:25 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> 
> Now that this has seen a bit of testing, and accumulated some fix 
> patches in -mm, can I get a roll-up of all those into a single patch?

I have a note that it has unresolved build problems, but I haven't seen
them for ages.

hrm.  Oh well, if they're there, they'll be fixed easily enough I guess.

> Looks OK to me.  My one minor comment is that I would think the 
> init_module() would be superfluous?
