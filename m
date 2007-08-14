From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Add device IDs of new 82571 board variants
Date: Tue, 14 Aug 2007 01:54:56 -0400
Message-ID: <46C143B0.70203@garzik.org>
References: <20070809210934.19268.45172.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bruce.w.allan@intel.com,
	john.ronciak@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52130 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S942348AbXHNFy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:54:59 -0400
In-Reply-To: <20070809210934.19268.45172.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> This patch adds support for 2 new board variants:
> - A Quad port fiber 82571 board
> - A blade version of the 82571 quad copper board
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_ethtool.c |    2 ++
>  drivers/net/e1000/e1000_hw.c      |    5 +++++
>  drivers/net/e1000/e1000_hw.h      |    3 +++
>  drivers/net/e1000/e1000_main.c    |    4 ++++
>  4 files changed, 14 insertions(+), 0 deletions(-)

applied


