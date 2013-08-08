From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 9 Aug 2013 00:09:18 +0300
Message-ID: <20130808210918.GE5502@mwanda>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, emilio@elopez.com.ar, mugunthanvnm@ti.com,
	jg1.han@samsung.com, hsweeten@visionengravers.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Kumar Gaurav <kumargauravgupta3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22449 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966649Ab3HHVJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 17:09:43 -0400
Content-Disposition: inline
In-Reply-To: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 09, 2013 at 12:50:49AM +0530, Kumar Gaurav wrote:
> Removed IRQF_DISABLED as it's no-op and should be removed
> 

What?  No, that doesn't sound right.

regards,
dan carpenter
