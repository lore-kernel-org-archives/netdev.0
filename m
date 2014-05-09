From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 0/2] Add DRA7xx platform support in cpsw-phy-sel driver
Date: Fri, 9 May 2014 19:02:39 +0530
Message-ID: <536CD8F7.9000603@ti.com>
References: <1399633404-5818-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42637 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbaEINcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 09:32:41 -0400
In-Reply-To: <1399633404-5818-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 May 2014 04:33 PM, Mugunthan V N wrote:
> Adding DRA7xx platform support to cpsw-phy-sel driver to select phy mode in
> control driver and fixing the uninitialized dev by initializing to platform
> device structure pointer.
>
> Mugunthan V N (2):
>   drivers: net: cpsw-phy-sel: add dra7xx support for phy sel
>   drivers: net: cpsw-phy-sel: add am43xx platform support
>
>  .../devicetree/bindings/net/cpsw-phy-sel.txt       |  4 +-
>  drivers/net/ethernet/ti/cpsw-phy-sel.c             | 61 +++++++++++++++++++++-
>  2 files changed, 63 insertions(+), 2 deletions(-)
>
Please ignore the patch as the second patch is not applicable and one
patch is missing.

Regards
Mugunthan V N
