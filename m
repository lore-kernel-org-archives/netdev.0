From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/6] atm/mpc.c warning fix
Date: Mon, 26 Jun 2006 00:02:11 -0700 (PDT)
Message-ID: <20060626.000211.21593943.davem@davemloft.net>
References: <200606250847.k5P8lWQq020909@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22427
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751286AbWFZHCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 03:02:12 -0400
To: akpm@osdl.org
In-Reply-To: <200606250847.k5P8lWQq020909@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Sun, 25 Jun 2006 01:47:32 -0700

> net/atm/mpc.c: In function 'MPOA_res_reply_rcvd':
> net/atm/mpc.c:1116: warning: unused variable 'ip'
> 
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks Andrew.
