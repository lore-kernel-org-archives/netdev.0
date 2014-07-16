From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: fix in netlink_filter_tap
Date: Tue, 15 Jul 2014 22:25:06 -0700 (PDT)
Message-ID: <20140715.222506.441840340242813808.davem@davemloft.net>
References: <1405487844-25969-1-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973AbaGPFZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 01:25:09 -0400
In-Reply-To: <1405487844-25969-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: varkabhadram@gmail.com
Date: Wed, 16 Jul 2014 10:47:24 +0530

> From: Varka Bhadram <varkab@cdac.in>
> 
> Remove the bool variable 'pass'. Return the true/false directly.
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

This doesn't "fix" anything, it's a cleanup.

Please resubmit this with a more correct commit header line and
commit message.
