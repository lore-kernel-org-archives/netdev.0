From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/13] cxgb3 - Expose HW memory page info
Date: Tue, 14 Aug 2007 01:44:32 -0400
Message-ID: <46C14140.2000104@garzik.org>
References: <20070811062954.8094.33064.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46754 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S942192AbXHNFoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:44:34 -0400
In-Reply-To: <20070811062954.8094.33064.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Let the RDMA driver get HW page info to work around HW issues.
> Assign explicit enum values.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

"HW issues" -- you need to go into far more detail, when adding a new 
interface.  what hw issues?  why was this the best/only solution?


