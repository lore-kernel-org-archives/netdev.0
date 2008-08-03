From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sat, 02 Aug 2008 19:26:39 -0700 (PDT)
Message-ID: <20080802.192639.02765648.davem@davemloft.net>
References: <20080802.122251.94384264.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365F1FBE8B37@rrsmsx501.amr.corp.intel.com>
	<EA929A9653AAE14F841771FB1DE5A1365F1FBE8B45@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47854
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751043AbYHCC0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 22:26:39 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8B45@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Sat, 2 Aug 2008 15:46:13 -0600

> Disregard my previous emails. This patch seems to fix the panic. I
> will leave a longer term stress test running to make sure it'stable.

Thanks for testing, I'll commit the final patch and get it to
Linus.

Thanks again.
