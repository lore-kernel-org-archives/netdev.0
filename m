From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: add support to dump
 ALE table via ethtool register dump
Date: Tue, 22 Jul 2014 22:05:01 +0530
Message-ID: <53CE92B5.5040805@ti.com>
References: <1406045756-10438-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42539 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbaGVQfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 12:35:07 -0400
In-Reply-To: <1406045756-10438-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 July 2014 09:45 PM, Mugunthan V N wrote:
> Add support to view addresses added by the driver and learnt by the
> hardware from ALE table via ethtool register dump interface.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

One build warning is there in this patch, will post v2 shortly

drivers/net/ethernet/ti/cpsw_ale.c: In function =91cpsw_ale_dump=92:
drivers/net/ethernet/ti/cpsw_ale.c:773:1: warning: control reaches end
of non-void function [-Wreturn-type]

Regards
Mugunthan V N
