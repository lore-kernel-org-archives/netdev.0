From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH] cxgb3i: ref count cdev access to prevent modification
 while in use
Date: Mon, 01 Aug 2011 09:42:57 -0500
Message-ID: <4E36BB71.6050400@opengridcomputing.com>
References: <1311623817-6417-1-git-send-email-nhorman@tuxdriver.com> <20110801111824.GB23131@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Divy Le Ray <divy@chelsio.com>,
	Steve Wise <swise@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Karen Xie <kxie@chelsio.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:45402 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751693Ab1HAOnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 10:43:01 -0400
In-Reply-To: <20110801111824.GB23131@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
>> CC: Divy Le Ray<divy@chelsio.com>
>> CC: Steve Wise<swise@chelsio.com>
>> CC: "David S. Miller"<davem@davemloft.net>
> Divy, Steve, I think Dave is waiting for an ACK from one of you to, since you're
> the listed maintainers.
> Neil

Karen is the cxgb3i maintainer, but I just now reviewed the patch and it looks good.  Divy is on vacation for a few 
weeks.  I think its ok to pull it in since Karen already acked it.

Steve.

