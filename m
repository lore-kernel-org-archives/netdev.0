From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Please pull 'upstream-davem' branch of wireless-2.6
Date: Thu, 20 Dec 2007 17:38:50 -0500
Message-ID: <20071220223850.GL3139@tuxdriver.com>
References: <20071220155321.GF3139@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2217 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756529AbXLTW6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 17:58:33 -0500
Content-Disposition: inline
In-Reply-To: <20071220155321.GF3139@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 20, 2007 at 10:53:21AM -0500, John W. Linville wrote:

> These are destined for 2.6.25.  The patches fall mostly into two
> categories: a new rate control algorithm for mac80211, and some
> cfg80211 enhancements (including mac80211 patches to use them).

>       mac80211: make PID rate control algorithm the default

This patch is busted.  I was mistaken about its readiness --
I apologize.  Don't pull if you haven't already.

We are actively working on fixing/replacing it.

Thanks for your patience!

John
-- 
John W. Linville
linville@tuxdriver.com
