From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] vxlan: virtual extensible lan
Date: Mon, 01 Oct 2012 18:40:38 -0400 (EDT)
Message-ID: <20121001.184038.1837923097802050289.davem@davemloft.net>
References: <20121001223232.566037595@vyatta.com>
	<20121001223254.349753999@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932364Ab2JAWkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 18:40:40 -0400
In-Reply-To: <20121001223254.349753999@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 01 Oct 2012 15:32:35 -0700

> This is an implementation of Virtual eXtensible Local Area Network
> as described in draft RFC:
>   http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02
> 
> The driver integrates a Virtual Tunnel Endpoint (VTEP) functionality
> that learns MAC to IP address mapping. 
> 
> This implementation has not been tested only against the Linux
> userspace implementation using TAP, not against other vendor's
> equipment.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
