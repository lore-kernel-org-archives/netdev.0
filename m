From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 08/13] ns8320: use netdev_alloc_skb
Date: Fri, 30 May 2008 22:20:56 -0400
Message-ID: <4840B608.4060603@pobox.com>
References: <20080416233727.732025083@vyatta.com> <20080416233757.549298900@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756513AbYEaCU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:20:58 -0400
In-Reply-To: <20080416233757.549298900@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Use netdev_alloc_skb. This sets skb->dev and allows arch specific
> allocation.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

applied


