From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 11:36:56 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161136220.15629@qirst.com>
References: <alpine.DEB.1.10.0904161035390.19650@qirst.com> <20090416151504.GA28978@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:43400 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446AbZDPPn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 11:43:59 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2FEA182C12B
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:53:52 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nstyEC2wPqS9 for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 11:53:52 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7CC9B82C2AD
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:53:47 -0400 (EDT)
In-Reply-To: <20090416151504.GA28978@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Neil Horman wrote:

> I think your comment is reveresed here isn't it?  the default you have below is
> that mc_all is set, which defaults you to the existing behavior, rather than the
> new behavior introduced by this patch.

mc_all is 0 by default.

> Ack to the patch though
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Neil

Thanks.

