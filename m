From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qlcnic: Validate Tx queue only for 82xx adapters.
Date: Fri, 18 Oct 2013 16:39:55 -0400 (EDT)
Message-ID: <20131018.163955.575448416725967173.davem@davemloft.net>
References: <ee136cd9c8e22123662b55a614e509277cfeba40.1382067199.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193Ab3JRUj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:39:56 -0400
In-Reply-To: <ee136cd9c8e22123662b55a614e509277cfeba40.1382067199.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Thu, 17 Oct 2013 18:26:38 -0400

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> o validate Tx queue only in case of adapters which supports
>   multi Tx queue.
> 
>   This patch is to fix regression introduced in commit
>   aa4a1f7df7cbb98797c9f4edfde3c726e2b3841f
>   "qlcnic: Enable Tx queue changes using ethtool for 82xx Series adapter"
> 
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

Applied, thanks.
