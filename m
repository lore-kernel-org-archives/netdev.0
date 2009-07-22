From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Avoid races in sky2_down
Date: Tue, 21 Jul 2009 21:00:26 -0700 (PDT)
Message-ID: <20090721.210026.96848786.davem@davemloft.net>
References: <392fb48f0907211750v101d51cbl531a6ed7199e4855@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750702AbZGVEAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 00:00:21 -0400
In-Reply-To: <392fb48f0907211750v101d51cbl531a6ed7199e4855@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Wed, 22 Jul 2009 09:50:41 +0900

> Reset rx chain before trying to drain it.
> Shut interrupts off last, incase there's something to report.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
