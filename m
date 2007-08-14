From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] e1000e: Fix header includes [v2]
Date: Tue, 14 Aug 2007 01:11:12 -0400
Message-ID: <46C13970.2040108@garzik.org>
References: <20070810200038.21509.77815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50045 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765773AbXHNFLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:11:15 -0400
In-Reply-To: <20070810200038.21509.77815.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c   |    4 ++++
>  drivers/net/e1000e/e1000.h   |    7 ++++---
>  drivers/net/e1000e/es2lan.c  |    5 +++++
>  drivers/net/e1000e/ethtool.c |    3 ++-
>  drivers/net/e1000e/hw.h      |    2 ++
>  drivers/net/e1000e/ich8lan.c |    5 +++++
>  drivers/net/e1000e/lib.c     |    2 ++
>  drivers/net/e1000e/netdev.c  |    2 ++
>  drivers/net/e1000e/phy.c     |    2 ++
>  9 files changed, 28 insertions(+), 4 deletions(-)

applied 1-6, however, comments follow...


