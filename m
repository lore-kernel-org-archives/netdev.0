From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: include NLM_F_REPLACE in route replace
 notifications
Date: Thu, 17 Sep 2015 15:00:38 -0700 (PDT)
Message-ID: <20150917.150038.1255165938220020001.davem@davemloft.net>
References: <1442164713-54206-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, mkubecek@suse.cz,
	Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbbIQWAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 18:00:39 -0400
In-Reply-To: <1442164713-54206-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Sun, 13 Sep 2015 10:18:33 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds NLM_F_REPLACE flag to ipv6 route replace notifications.
> This makes nlm_flags in ipv6 replace notifications consistent
> with ipv4.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> Submitting this to net since it complements the other ipv6 replace fixes
> in net

Applied, thanks Roopa.
