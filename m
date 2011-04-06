From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 07/12] igbvf: remove bogus phys_id
Date: Wed, 06 Apr 2011 14:31:53 -0700 (PDT)
Message-ID: <20110406.143153.58445588.davem@davemloft.net>
References: <20110404184340.604594357@linuxplumber.net>
	<20110404184501.915865252@linuxplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53202
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932225Ab1DFVca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:32:30 -0400
In-Reply-To: <20110404184501.915865252@linuxplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 04 Apr 2011 11:43:47 -0700

> This device lies about supporting phys_id. Remove it and just
> let the upper layer report not supported.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Deferred to Intel driver maintainers.
