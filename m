From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 00:50:41 -0700 (PDT)
Message-ID: <20120626.005041.1698348008856448478.davem@davemloft.net>
References: <1340695993-1911-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120626.004302.1065943933933136878.davem@davemloft.net>
	<1340696980.2255.18.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145Ab2FZHum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:50:42 -0400
In-Reply-To: <1340696980.2255.18.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 Jun 2012 00:49:40 -0700

> On Tue, 2012-06-26 at 00:43 -0700, David Miller wrote:
>> You can't put things like "[3.4]" unquoted into the CC: list, that's
>> not kosher and vger rejected it.
> 
> Re-sent with the proper quoting.

Doesn't work, see my reply.
