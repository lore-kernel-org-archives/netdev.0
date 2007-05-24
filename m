From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/4] forcedeth: fix cpu irq mask
Date: Thu, 24 May 2007 18:03:36 -0400
Message-ID: <46560BB8.4010605@garzik.org>
References: <465237EF.60302@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48571 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbXEXWDj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 18:03:39 -0400
In-Reply-To: <465237EF.60302@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch fixes the cpu irq mask define to include the timer irq. 
> Another flag check was setting up the timer bit in all cases so we 
> didn't notice the issue.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied to #upstream-fixes


