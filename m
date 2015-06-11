From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: igb: fix the start time for periodic output
 signals
Date: Thu, 11 Jun 2015 15:56:27 -0700 (PDT)
Message-ID: <20150611.155627.1888601708793677012.davem@davemloft.net>
References: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
	<20150611125310.GA26906@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
	jeffrey.t.kirsher@intel.com, matthew.vick@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754598AbbFKW42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 18:56:28 -0400
In-Reply-To: <20150611125310.GA26906@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 11 Jun 2015 14:53:10 +0200

> On Thu, Jun 11, 2015 at 02:51:30PM +0200, Richard Cochran wrote:
>> This patch fixes the issue by programming the registers correctly.
> 
> Please also consider this for stable.

Jeff, do you want me to integrate this directly?
