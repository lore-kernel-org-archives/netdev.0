From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21 1/4] cxgb3 - Safeguard TCAM size usage
Date: Tue, 03 Apr 2007 22:31:30 -0400
Message-ID: <46130E02.3020806@garzik.org>
References: <20070331072313.4694.92549.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40237 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966268AbXDDCbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 22:31:34 -0400
In-Reply-To: <20070331072313.4694.92549.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Ensure that the TCAM active region size is at least 16.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/common.h        |    3 +++
>  drivers/net/cxgb3/cxgb3_main.c    |    7 +++++--
>  drivers/net/cxgb3/cxgb3_offload.c |    4 +++-
>  3 files changed, 11 insertions(+), 3 deletions(-)

applied 1-4


