From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] rocker cleanups
Date: Thu, 26 Feb 2015 11:22:28 -0500 (EST)
Message-ID: <20150226.112228.697728252846216119.davem@davemloft.net>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbbBZQWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:22:30 -0500
In-Reply-To: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 25 Feb 2015 20:15:35 -0800

> Pushing out some rocker cleanups I've had in my queue for a while.  Nothing
> major, just some sync-up with changes that already went into device code
> (hard-coding desc err return values and lport renaming).  Also fixup
> port fowarding transitions prompted by some DSA discussions about how to
> restore port state when port leaves bridge.

Series applied, thanks Scott.
