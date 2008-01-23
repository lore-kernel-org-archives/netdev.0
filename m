From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pci-skeleton: Misc fixes to build neatly
Date: Wed, 23 Jan 2008 04:59:21 -0500
Message-ID: <47970FF9.7010009@garzik.org>
References: <df9815e70801212216v79ff8137kccc6a94ddb96c818@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jike Song <albcamus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47157 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbYAWJ7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 04:59:23 -0500
In-Reply-To: <df9815e70801212216v79ff8137kccc6a94ddb96c818@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jike Song wrote:
> Hello Jeff,
> 
> The pci-skeleton.c has several problems with compilation, such as missing args
> when calling synchronize_irq(). Fix it.
> 
> Signed-off-by: Jike Song <albcamus@gmail.com>
> ---
>  drivers/net/pci-skeleton.c |   49 ++++++++++++++++++++++---------------------
>  1 files changed, 25 insertions(+), 24 deletions(-)

ACK but git-am (everybody's patch import tool) says the patch is corrupted


