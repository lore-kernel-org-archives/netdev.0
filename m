From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next] net/mlx5_core: Set log_uar_page_sz for non 4K
 page size architecture
Date: Thu, 6 Aug 2015 14:01:11 +0300
Message-ID: <55C33E77.2090005@mellanox.com>
References: <1438790732-29819-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	Eli Cohen <eli@mellanox.com>, Majd Dibbiny <majd@mellanox.com>
To: "clsoto@linux.vnet.ibm.com" <clsoto@linux.vnet.ibm.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0062.outbound.protection.outlook.com ([157.56.112.62]:1920
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754686AbbHFLRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 07:17:00 -0400
In-Reply-To: <1438790732-29819-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/5/2015 7:05 PM, clsoto@linux.vnet.ibm.com wrote:
> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
> 
> failed to configure the page size for architectures with page size
> different than 4K.
> 
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
> ---

Please pull this patch into kernel 4.2

Fixes: 938fe83 ("net/mlx5_core: New device capabilities handling")
Acked-by: Amir Vadai <amirv@mellanox.com>
