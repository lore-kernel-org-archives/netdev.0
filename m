From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2 0/2] Fix system hang when loading mvneta module -
 take 2
Date: Tue, 30 Jul 2013 19:32:55 -0700 (PDT)
Message-ID: <20130730.193255.1830316236868115039.davem@davemloft.net>
References: <20130729195646.433524957@rtp-net.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: arnaud.patard@rtp-net.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab3GaCc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:32:56 -0400
In-Reply-To: <20130729195646.433524957@rtp-net.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Date: Mon, 29 Jul 2013 21:56:46 +0200

> This is a second version of my patchset to fix mvneta as module.
> I've addressed previous comments. I've also fixed probe
> error path which was broken in the previous version.

Both applied, thanks.
