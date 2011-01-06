From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Re: spurious netconsole: network logging stopped
 messages
Date: Thu, 06 Jan 2011 11:30:46 -0800 (PST)
Message-ID: <20110106.113046.246528563.davem@davemloft.net>
References: <87bp3yq60w.fsf@tac.ki.iif.hu>
	<cover.1294326001.git.wferi@niif.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wferi@niif.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751580Ab1AFTaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:30:15 -0500
In-Reply-To: <cover.1294326001.git.wferi@niif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ferenc Wagner <wferi@niif.hu>
Date: Thu,  6 Jan 2011 16:11:18 +0100

> Hi,
> 
> I've been running with these two patches for a couple of days now.
> I don't understand the bridge case: why should netconsole stop logging
> on a bridge device which lost a slave?  Or does NETDEV_BONDING_DESLAVE
> mean something else?
> 
> Anyway, I think the first patch fixes a real bug and the second makes
> the kernel message clearer, independently of its cause.

Both applied, thank you.
