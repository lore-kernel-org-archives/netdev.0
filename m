From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qlcnic: Bug fix for LRO
Date: Fri, 23 Mar 2012 14:52:52 -0400 (EDT)
Message-ID: <20120323.145252.220010012654046251.davem@davemloft.net>
References: <1332520354-22519-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822Ab2CWSw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 14:52:58 -0400
In-Reply-To: <1332520354-22519-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Fri, 23 Mar 2012 09:32:34 -0700

>  - After FW reset, IP addresses need to be reprogrammed to FW for LRO to work. This
>    was not happening in context reset path. Fixed it here.
>  - Updated driver version to 5.0.27
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.
