From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: Fix ethtool register test code
Date: Fri, 05 Oct 2007 13:56:08 -0400
Message-ID: <47067AB8.1030105@garzik.org>
References: <20071004220008.3344.59536.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47882 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756135AbXJER4K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 13:56:10 -0400
In-Reply-To: <20071004220008.3344.59536.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> A merge/cleanup code accidentally dropped 8254x code in and removed
> 8257x code here. Undo this mistake and use the pci-e relevant register
> test similar as to what is in e1000.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/ethtool.c |   14 ++++++++++----
>  1 files changed, 10 insertions(+), 4 deletions(-)

applied


