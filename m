From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: fix beaconing test for 82xx adapter
Date: Wed, 17 Apr 2013 01:15:48 -0400 (EDT)
Message-ID: <20130417.011548.2136789547169090034.davem@davemloft.net>
References: <1366171870-15793-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	himanshu.madhani@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756982Ab3DQFPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 01:15:50 -0400
In-Reply-To: <1366171870-15793-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Wed, 17 Apr 2013 00:11:10 -0400

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> o Commit 319ecf121e1da3d75dd1bde32fed255532e61797
>   ("qlcnic: 83xx sysfs routines") introduced regression
>   for beaconing test while refactoring 82xx code. This patch is to
>   revert code to fix beaconing test for 82xx adapter.
> 
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Applied.
