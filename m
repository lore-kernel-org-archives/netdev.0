From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ucc_geth: add ethtool support
Date: Tue, 24 Jul 2007 16:36:29 -0400
Message-ID: <46A662CD.2020604@garzik.org>
References: <11848168673403-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58958 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757391AbXGXUgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:36:31 -0400
In-Reply-To: <11848168673403-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Li Yang wrote:
> The patch enables statistics in ucc_geth and adds ethtool support to
> ucc_geth driver.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
>  drivers/net/Makefile           |    2 +-
>  drivers/net/ucc_geth.c         |   19 +-
>  drivers/net/ucc_geth.h         |    6 +
>  drivers/net/ucc_geth_ethtool.c |  388 ++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ucc_geth_mii.c     |    6 +-
>  5 files changed, 407 insertions(+), 14 deletions(-)
>  create mode 100644 drivers/net/ucc_geth_ethtool.c

applied 1-2


