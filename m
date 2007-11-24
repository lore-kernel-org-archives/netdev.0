From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/9] cxgb3 - fix MSI-X failure path
Date: Fri, 23 Nov 2007 22:00:04 -0500
Message-ID: <474793B4.6020105@garzik.org>
References: <20071116192139.31024.31482.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43496 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663AbXKXDAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:00:11 -0500
In-Reply-To: <20071116192139.31024.31482.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Return error code when msi-x settings fail.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/cxgb3_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)

applied 1-9 to #upstream, then trimmed all trailing whitespace


