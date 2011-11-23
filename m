From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/10] bql: Byte Queue Limits
Date: Wed, 23 Nov 2011 18:59:30 -0500 (EST)
Message-ID: <20111123.185930.873414204064925516.davem@davemloft.net>
References: <alpine.DEB.2.00.1111222134590.9126@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab1KWX7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 18:59:33 -0500
In-Reply-To: <alpine.DEB.2.00.1111222134590.9126@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 22 Nov 2011 21:52:12 -0800 (PST)

> This patch series implements byte queue limits (bql) for NIC TX queues.

No fundamental objections from me.

Please address the feedback (in particular the dql data structure layout,
32-bit counters, and getting rid of the config options).
