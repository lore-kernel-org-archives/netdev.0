From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: remove superfluous assignment
Date: Sun, 01 Jun 2014 22:11:12 -0700 (PDT)
Message-ID: <20140601.221112.404024295255338615.davem@davemloft.net>
References: <1401346448-17105-1-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaFBFLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 01:11:13 -0400
In-Reply-To: <1401346448-17105-1-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cheng Renquan <crquan@gmail.com>
Date: Wed, 28 May 2014 23:54:08 -0700

> the local variable ops and n_ops were just read out from family,
> and not changed, why need to assign back?
> 
> Validation functions should operate on const parameters and not
> change anything.
> 
> Signed-off-by: Cheng Renquan <crquan@gmail.com>

This patch was corrupted by your email client, please fix this up
and resubmit.
