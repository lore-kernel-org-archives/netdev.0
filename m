From: Stephen Boyd <sboyd@codeaurora.org>
Subject: Re: [PATCH] ks8851: Fix request_irq/free_irq mismatch
Date: Thu, 19 Apr 2012 11:13:51 -0700
Message-ID: <4F9055DF.9050509@codeaurora.org>
References: <1334855837-28366-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, netdev@vger.kernel.org
To: mjr@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:31295 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab2DSSNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 14:13:52 -0400
In-Reply-To: <1334855837-28366-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/12 10:17, mjr@cs.wisc.edu wrote:
> From: Matt Renzelmann <mjr@cs.wisc.edu>
>
> The dev_id parameter passed to free_irq needs to match the one passed
> to the corresponding request_irq.
>
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>

Acked-by: Stephen Boyd <sboyd@codeaurora.org>

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
