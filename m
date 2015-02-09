From: David Miller <davem@redhat.com>
Subject: Re: [PATCHv2 net-next 0/3] Add support in ethtool to get expansion
 ROM version
Date: Mon, 09 Feb 2015 14:08:24 -0800 (PST)
Message-ID: <20150209.140824.1105029746035917676.davem@redhat.com>
References: <1423463851-19073-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371AbbBIWIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 17:08:30 -0500
In-Reply-To: <1423463851-19073-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  9 Feb 2015 12:07:28 +0530

> This series adds support to get expansion ROM version via ethtool getdrvinfo.
> PATCH 1/3 ("ethtool: rename reserved1 memeber in ethtool_drvinfo for expansion
>     ROM version") is created against net-next tree.
> PATCH 2/3 ("cxgb4: Add support in cxgb4 to get expansion rom version via
> ethtool") is created against net-next tree.
> PATCH 3/3 ("ethtool: Add support to get expansion ROM version in ethtool
> getdrvinfo") is created against ethtool tree.
> 
> We have included all the maintainers of respective trees. Kindly review the
> change and let us know in case of any review comments.
 ...
> V2: Use MACRO instead of hardcoded value for EROM version string len. Based on
> review comment by David Miller.

Patch 1 and 2 applied to net-next, thanks.
