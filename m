From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] More const ops cleanups
Date: Wed, 02 Sep 2009 00:46:37 -0700 (PDT)
Message-ID: <20090902.004637.20855409.davem@davemloft.net>
References: <20090902052500.808557262@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59943
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750726AbZIBHqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 03:46:22 -0400
In-Reply-To: <20090902052500.808557262@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 01 Sep 2009 22:25:00 -0700

> Many places were not using const when defining/using structures
> that only contain initialized values.

All applied to net-next-2.6

Nice work Stephen.
