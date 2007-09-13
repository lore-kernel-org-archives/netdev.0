From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ethtool: add register dump support for intel 82575
 chipsets (igb driver)
Date: Thu, 13 Sep 2007 00:15:09 -0400
Message-ID: <46E8B94D.4040104@garzik.org>
References: <20070815174401.15938.53561.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	nicholas.d.nunley@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40018 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809AbXIMEPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:15:12 -0400
In-Reply-To: <20070815174401.15938.53561.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Nicholas Nunley <nicholas.d.nunley@intel.com>
> 
> Signed-off-by: Nicholas Nunley <nicholas.d.nunley@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  Makefile.am    |    2 
>  ethtool-util.h |    2 
>  ethtool.c      |    1 
>  igb.c          |  864 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 868 insertions(+), 1 deletions(-)

applied 1-2


