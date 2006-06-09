From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/9] selinux: add security class for appletalk sockets
Date: Fri, 09 Jun 2006 00:26:47 -0700 (PDT)
Message-ID: <20060609.002647.35467429.davem@davemloft.net>
References: <200606090520.k595KqQU032083@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cpebenito@tresys.com, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4512
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751400AbWFIH1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:27:32 -0400
To: akpm@osdl.org
In-Reply-To: <200606090520.k595KqQU032083@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Thu, 08 Jun 2006 22:20:52 -0700

> 
> From: Christopher J. PeBenito <cpebenito@tresys.com>
> 
> Add a security class for appletalk sockets so that they can be
> distinguished in SELinux policy.  Please apply.
> 
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> Acked-by: James Morris <jmorris@namei.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.18, thanks.
