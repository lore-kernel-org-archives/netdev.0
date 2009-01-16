From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH][TCP]: simplify tcp_mark_lost_retrans()
Date: Fri, 16 Jan 2009 22:13:05 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901162211230.14426@wrl-59.cs.helsinki.fi>
References: <alpine.DEB.2.00.0901071009000.6102@rhea>
 <Pine.LNX.4.64.0901071229160.27307@wrl-59.cs.helsinki.fi>
 <4964D4E2.8050602@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41091 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755942AbZAPUNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 15:13:07 -0500
In-Reply-To: <4964D4E2.8050602@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Jan 2009, Arnd Hannemann wrote:

> Perhaps it would be better to let the comments reflect
> what you just said and remove the redundant check
> anyway to reduce the dead code a newcomer has to understand ;-)
> I would have included a patch for the comments, but as you have a
> deeper understanding of the code it would probably
> be better if you can do it.

I have a patch for this in a local tree and will submit it among
other TCP stuff (later on).


-- 
 i.
