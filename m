From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] vxlan: remove the unnecessary codes
Date: Wed, 22 Apr 2015 18:46:01 -0400 (EDT)
Message-ID: <20150422.184601.536740847110194246.davem@davemloft.net>
References: <1429688950-10450-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbbDVWqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:46:03 -0400
In-Reply-To: <1429688950-10450-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 22 Apr 2015 15:49:10 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The return value of vxlan_fdb_replace always is greater than or equal to 0
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
