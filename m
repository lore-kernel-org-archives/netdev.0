From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] forcedeth: add MII ioctls support
Date: Thu, 12 Dec 2013 13:56:44 -0500 (EST)
Message-ID: <20131212.135644.122378813786715365.davem@davemloft.net>
References: <1386829089-24477-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, kaber@trash.net, Larry.Finger@lwfinger.net,
	peterz@infradead.org, netdev@vger.kernel.org
To: noureddine@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab3LLS4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 13:56:46 -0500
In-Reply-To: <1386829089-24477-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@aristanetworks.com>
Date: Wed, 11 Dec 2013 22:18:09 -0800

> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

I agree with Florian that using phylib would be a cleaner way to get
this facility (and more).
