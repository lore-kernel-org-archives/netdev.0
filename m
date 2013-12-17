From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: git problems
Date: Tue, 17 Dec 2013 21:02:04 +0100
Message-ID: <20131217200204.GE18396@order.stressinduktion.org>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B74A0@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34402 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab3LQUCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:02:06 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B74A0@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 05:21:05PM -0000, David Laight wrote:
> git managed to completely trash my tree - no problem I'd saved everything important.
> So I renamed the directory tree and then checked out an entire new tree.
> Now it won't let me commit because it has somewhere remembered a merge f*ckup
> in the old tree.
> Where has it got this info saved, and how do I tell it there is nothing wrong?

git merge --abort maybe?
