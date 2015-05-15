From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Thu, 14 May 2015 22:45:54 -0400 (EDT)
Message-ID: <20150514.224554.1382655632305683978.davem@davemloft.net>
References: <1431577061-12517-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422886AbbEOCp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 22:45:57 -0400
In-Reply-To: <1431577061-12517-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Wed, 13 May 2015 21:17:41 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.
> 
> This patch renames the flag to be consistent with what the user sees.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
