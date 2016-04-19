From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] drivers: net: cpsw: Prevent NUll pointer
 dereference with two PHYs
Date: Tue, 19 Apr 2016 18:43:39 -0400 (EDT)
Message-ID: <20160419.184339.1558043853032502121.davem@davemloft.net>
References: <57165269.40207@ti.com>
	<20160419131443.7a3b3ef7.drivshin.allworx@gmail.com>
	<57167C79.20205@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drivshin.allworx@gmail.com, andrew.goodbody@cambrionix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, mugunthanvnm@ti.com, tony@atomide.com
To: grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcDSWnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 18:43:45 -0400
In-Reply-To: <57167C79.20205@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Tue, 19 Apr 2016 21:44:09 +0300

> May be you can send revert + your patch 1 (only fix for this issue).
> 
> Dave, Does that sound good to you?

Sure.
