From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 4/4] bonding: Fix some RTNL taking
Date: Fri, 18 Jan 2008 18:06:40 +0900
Message-ID: <47906C20.1000104@miraclelinux.com>
References: <20080116124450.GD2307@ff.dom.local> <478EE7FD.3010802@miraclelinux.com> <20080117114655.GC1710@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:30172 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbYARJI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 04:08:26 -0500
In-Reply-To: <20080117114655.GC1710@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Probably the difference is not much, but since this all double locking,
> unlocking and something between could take a while, and such a check
> looks cheaper than re-queueing... But I don't persist in this.
Looks like this one is settled, thank you for your advice!

--
Makito SHIOKAWA
MIRACLE LINUX CORPORATION
