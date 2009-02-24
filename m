From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/5] netxen: fix physical port mapping
Date: Tue, 24 Feb 2009 04:20:39 -0800 (PST)
Message-ID: <20090224.042039.252782451.davem@davemloft.net>
References: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
	<9FB481EF4C70734186A21A64437F637C02A10E5607@nxexch.unminc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758116AbZBXMU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 07:20:58 -0500
In-Reply-To: <9FB481EF4C70734186A21A64437F637C02A10E5607@nxexch.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue, 24 Feb 2009 00:13:26 -0800

> Please hold off this 5 patch series. I have two critical bug fixes
> that take priority and will probably clash the pci probe
> re-factoring patch.

Ok, I tossed them.

I've pulled net-2.6 into net-next-2.6 so you should be able to
respin your patches on top of the bug fixes using that.

Thanks.
