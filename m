From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] mpls: support for dead routes
Date: Tue, 03 Nov 2015 10:28:02 -0500 (EST)
Message-ID: <20151103.102802.1746914891520356480.davem@davemloft.net>
References: <1446527581-64787-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbbKCP2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:28:06 -0500
In-Reply-To: <1446527581-64787-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon,  2 Nov 2015 21:13:01 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
> routes due to link events. Also adds code to ignore dead
> routes during route selection
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Robert found more issues, I think this is going to have to wait until the
next merge window Roopa...
