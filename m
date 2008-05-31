From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 13/13] acenic: use netdev_alloc_skb
Date: Fri, 30 May 2008 22:21:05 -0400
Message-ID: <4840B611.5060406@pobox.com>
References: <20080416233727.732025083@vyatta.com> <20080416233757.925572770@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	linux-acenic@sunsite.dk
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54367 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753568AbYEaCVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:21:08 -0400
In-Reply-To: <20080416233757.925572770@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Use netdev_alloc_skb. This sets skb->dev and allows arch specific
> allocation.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 

applied


