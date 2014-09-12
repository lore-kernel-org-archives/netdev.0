From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet: amd: use pr_info_once()
Date: Fri, 12 Sep 2014 18:03:15 -0400 (EDT)
Message-ID: <20140912.180315.1259712794955554092.davem@davemloft.net>
References: <1410420050-16088-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas.Lendacky@amd.com, varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbaILWDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 18:03:18 -0400
In-Reply-To: <1410420050-16088-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkabhadram@gmail.com>
Date: Thu, 11 Sep 2014 12:50:50 +0530

> It will use pr_info_one() to print the version info of the
> driver in probe function only once. No need to use the static
> variable here.
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Applied, thank you.
