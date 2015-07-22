From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: make RTA_OIF optional
Date: Tue, 21 Jul 2015 22:27:30 -0700 (PDT)
Message-ID: <20150721.222730.616094018660661487.davem@davemloft.net>
References: <1437495384-15023-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbGVF1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:27:31 -0400
In-Reply-To: <1437495384-15023-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 21 Jul 2015 09:16:24 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> If user did not specify an oif, try and get it from the via address.
> If failed to get device, return with -ENODEV.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
