From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Use proper Rx flow control register
Date: Fri, 23 Jan 2015 22:18:04 -0800 (PST)
Message-ID: <20150123.221804.251517843729287609.davem@davemloft.net>
References: <20150120182031.20236.62843.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbAXGSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 01:18:06 -0500
In-Reply-To: <20150120182031.20236.62843.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 20 Jan 2015 12:20:31 -0600

> Updated hardware documention shows the Rx flow control settings were
> moved from the Rx queue operation mode register to a new Rx queue flow
> control register.  The old flow control settings are now reserved areas
> of the Rx queue operation mode register. Update the code to use the new
> register.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks TOm.
