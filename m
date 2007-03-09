From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] e1000: Use ARRAY_SIZE macro when appropriate
Date: Fri, 09 Mar 2007 12:00:21 -0500
Message-ID: <45F192A5.1000309@garzik.org>
References: <20070306165802.27452.22955.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57933 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767414AbXCIRAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 12:00:22 -0500
In-Reply-To: <20070306165802.27452.22955.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Ahmed S. Darwish <darwish.07@gmail.com>
> 
> A patch to use ARRAY_SIZE macro already defined in kernel.h.
> 
> Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied 1-3 to #upstream


