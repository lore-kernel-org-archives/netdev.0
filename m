From: David Miller <davem@davemloft.net>
Subject: Re: [patch 9/9] secmark: Add new packet controls to SELinux
Date: Fri, 09 Jun 2006 00:33:59 -0700 (PDT)
Message-ID: <20060609.003359.118950131.davem@davemloft.net>
References: <200606090520.k595Kx8J032108@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58584
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751418AbWFIHeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:34:44 -0400
To: akpm@osdl.org
In-Reply-To: <200606090520.k595Kx8J032108@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Thu, 08 Jun 2006 22:20:59 -0700

> Add new per-packet access controls to SELinux, replacing the old packet
> controls.
 ...
> Signed-off-by: James Morris <jmorris@namei.org>
> Cc: Stephen Smalley <sds@tycho.nsa.gov>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.18, thanks a lot.
