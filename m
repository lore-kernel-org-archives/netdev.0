From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make atm/he.c:read_prom_byte() static
Date: Mon, 31 Mar 2008 19:35:15 -0700 (PDT)
Message-ID: <20080331.193515.236966132.davem@davemloft.net>
References: <20080330231155.GZ28445@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56291
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751784AbYDACfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 22:35:15 -0400
In-Reply-To: <20080330231155.GZ28445@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 31 Mar 2008 02:11:55 +0300

> This patch makes the needlessly global read_prom_byte() static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied.
