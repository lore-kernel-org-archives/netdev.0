From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/9] bnep endianness bug: filtering by packet type
Date: Wed, 08 Nov 2006 22:43:48 -0800 (PST)
Message-ID: <20061108.224348.08652139.davem@davemloft.net>
References: <200611090351.kA93p7gO003690@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ftp.linux.org.uk, marcel@holtmann.org,
	viro@zeniv.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7568
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754756AbWKIGnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 01:43:43 -0500
To: akpm@osdl.org
In-Reply-To: <200611090351.kA93p7gO003690@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Wed, 08 Nov 2006 19:51:07 -0800

> From: Al Viro <viro@ftp.linux.org.uk>
> 
> <= and => don't work well on net-endian...
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Also already in my net-2.6.20 tree
