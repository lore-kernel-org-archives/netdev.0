From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] ixgb: increase skb size to prevent dma over skb
 boundary
Date: Tue, 08 Dec 2009 01:27:47 -0800 (PST)
Message-ID: <20091208.012747.52087810.davem@davemloft.net>
References: <20091207144922.GD8073@hmsreliant.think-freely.org>
	<9929d2390912071254v24eb6980s1b43cf2e6f86f1dc@mail.gmail.com>
	<20091207205702.GI8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45681
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751275AbZLHJ1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 04:27:42 -0500
In-Reply-To: <20091207205702.GI8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 7 Dec 2009 15:57:02 -0500

> Um, Well, its already submitted to dave and netdev, but an ACK would
> sure be appreciated pending your review. :)

Since the Intel folks are very responsive, I let all Intel driver
patches flow through Jeff's submission process.
