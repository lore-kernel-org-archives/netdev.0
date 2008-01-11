From: David Miller <davem@davemloft.net>
Subject: Re: questions on NAPI processing latency and dropped network
 packets
Date: Thu, 10 Jan 2008 17:20:49 -0800 (PST)
Message-ID: <20080110.172049.118174993.davem@davemloft.net>
References: <478654C3.60806@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755028AbYAKBUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 20:20:54 -0500
In-Reply-To: <478654C3.60806@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Thu, 10 Jan 2008 11:24:19 -0600

> I've got an issue that's popped up with a deployed system running 
> 2.6.10.
 ...
> So...anyone have any ideas/suggestions?

You have to be kidding, coming here for help with a nearly
4 year old kernel.

The networking stack as well as the e1000 driver has been
practically rewritten several times over since then.
