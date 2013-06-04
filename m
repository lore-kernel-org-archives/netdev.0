From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] xfrm: simplify the exit path of
 xfrm_output_one()
Date: Tue, 04 Jun 2013 15:19:10 -0700 (PDT)
Message-ID: <20130604.151910.1689815710133382671.davem@davemloft.net>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab3FDWTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 18:19:11 -0400
In-Reply-To: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sat,  1 Jun 2013 20:23:15 -0600

> Clean up unnecessary assignment and jump. While there, fix up the label
> name.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied.
