From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] bridge: get rid of miscdevice include
Date: Thu, 22 Feb 2007 01:09:05 -0800 (PST)
Message-ID: <20070222.010905.57155690.davem@davemloft.net>
References: <20070221224107.741532037@linux-foundation.org>
	<20070221224255.581096490@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60341
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932889AbXBVJJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 04:09:06 -0500
In-Reply-To: <20070221224255.581096490@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 21 Feb 2007 14:41:08 -0800

> The bridge hasn't used miscdevice for a long long time.

Applied, thanks Stephen.

> Signed-off-by: StephenHemminger <shemminger@linux-foundtion.org>
                      ^^^^                              ^^^^

You don't type these in by hand do you? :-)

Time to put your signoff into a text file and use the insert-from-file
feature of your favorite editor or similar :-)
