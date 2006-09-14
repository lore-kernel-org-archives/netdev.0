From: David Miller <davem@davemloft.net>
Subject: Re: examples to model ethernet driver off of?
Date: Wed, 13 Sep 2006 18:40:03 -0700 (PDT)
Message-ID: <20060913.184003.71102937.davem@davemloft.net>
References: <20060913195445.GH25007@electric-eye.fr.zoreil.com>
	<450865DB.4040809@intel.com>
	<20060914102610.6e4dc766@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, romieu@fr.zoreil.com,
	galak@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49568
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751326AbWINBjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 21:39:13 -0400
To: shemminger@osdl.org
In-Reply-To: <20060914102610.6e4dc766@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 14 Sep 2006 10:26:10 +0900

> sorry to pick on e1000, but the code is too verbose and
> split over too many files.  The e100 code is much cleaner.

I totally agree, I would never use e1000 as a model
driver for someone writing some new code.
