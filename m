From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Thu, 31 Jan 2008 18:37:55 -0800 (PST)
Message-ID: <20080131.183755.226728080.davem@davemloft.net>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44148
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756931AbYBAChd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 21:37:33 -0500
In-Reply-To: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 31 Jan 2008 18:58:02 +0100 (MET)

> These patches add support for external classifiers to SFQ and add a
> new "flow" classifier, which can do hashing based on user-specified
> keys or deterministic mapping of keys to classes. Additionally there
> is a patch to make the SFQ queues visisble as classes to verify that
> the hash is indeed doing something useful and a patch to consifiy
> struct tcf_ext_map, which I had queued in the same tree.
> 
> Please apply, thanks.

Applied, thanks Patrick.
