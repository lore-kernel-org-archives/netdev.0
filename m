From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] Altera TSE: Set version number by
 driver's get regs
Date: Fri, 21 Mar 2014 15:36:59 -0400 (EDT)
Message-ID: <20140321.153659.2163629794696602595.davem@davemloft.net>
References: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
	<1395366197-9781-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbaCUThC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 15:37:02 -0400
In-Reply-To: <1395366197-9781-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Thu, 20 Mar 2014 20:43:15 -0500

> Set the version number returned by the driver's get regs routine
> invoked by ethtool so formatting can be dependent on the version
> number returned, and any interesting formatted output can check
> the version number for specific types of register data returned.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>

Applied.
