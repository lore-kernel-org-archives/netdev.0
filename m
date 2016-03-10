From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: libertas: fix an error code in probe
Date: Thu, 10 Mar 2016 12:57:24 +0000 (UTC)
Message-ID: <20160310125724.879A060DB3@smtp.codeaurora.org>
References: <20160308120408.GA28684@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andreas Kemnade <andreas@kemnade.info>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44427 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbcCJM5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 07:57:25 -0500
In-Reply-To: <20160308120408.GA28684@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> We accidentally return success instead of a negative error code.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
