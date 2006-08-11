From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbor: use ALIGN() macro
Date: Thu, 10 Aug 2006 23:03:52 -0700 (PDT)
Message-ID: <20060810.230352.00775127.davem@davemloft.net>
References: <20060810113403.6d46e567@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11223
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751551AbWHKGDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 02:03:43 -0400
To: shemminger@osdl.org
In-Reply-To: <20060810113403.6d46e567@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 10 Aug 2006 11:34:03 -0700

> Rather than opencoding the mask, it looks better to use ALIGN()
> macro from kernel.h.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
