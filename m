From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Fri, 19 Oct 2007 09:35:38 -0500
Message-ID: <4718C0BA.5060800@freescale.com>
References: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Emil Medve <Emilian.Medve@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:35155 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802AbXJSOgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 10:36:06 -0400
In-Reply-To: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emil Medve wrote:
> drivers/net/ucc_geth.c: In function 'ucc_geth_startup':
> drivers/net/ucc_geth.c:2614: warning: assignment makes integer from pointer without a cast
> drivers/net/ucc_geth.c:2651: warning: assignment makes integer from pointer without a cast
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>

Acked-by: Timur Tabi <timur@freescale.com>

