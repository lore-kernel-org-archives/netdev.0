From: David Miller <davem@davemloft.net>
Subject: Re: [patch 8/9] rfcomm endianness bug: param_mask is little-endian
 on the wire
Date: Wed, 08 Nov 2006 22:43:24 -0800 (PST)
Message-ID: <20061108.224324.14943901.davem@davemloft.net>
References: <200611090351.kA93pApj003699@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ftp.linux.org.uk, marcel@holtmann.org,
	viro@zeniv.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4496
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754751AbWKIGnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 01:43:19 -0500
To: akpm@osdl.org
In-Reply-To: <200611090351.kA93pApj003699@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Wed, 08 Nov 2006 19:51:10 -0800

> From: Al Viro <viro@ftp.linux.org.uk>
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Also already in my net-2.6.20 tree.
