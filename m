From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] igb: remove references to long gone command line
 parameters
Date: Tue, 18 Mar 2014 13:26:19 -0400 (EDT)
Message-ID: <20140318.132619.2223975262450406546.davem@davemloft.net>
References: <1395127610-3290-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fernando_b1@lab.ntt.co.jp, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, fernando@oss.ntt.co.jp
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757310AbaCRR0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:26:24 -0400
In-Reply-To: <1395127610-3290-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Mar 2014 00:26:48 -0700

> From: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
> 
> Command line parameters QueuePairs, Node, EEE, DMAC and InterruptThrottleRate
> do not exist these days. Remove all references to them in the Documentation
> folder and update code comments.
> 
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
