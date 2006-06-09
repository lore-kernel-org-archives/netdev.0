From: David Miller <davem@davemloft.net>
Subject: Re: [patch 7/9] secmark: Add secmark support to conntrack
Date: Fri, 09 Jun 2006 00:32:01 -0700 (PDT)
Message-ID: <20060609.003201.95504672.davem@davemloft.net>
References: <200606090520.k595KvVd032101@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10648
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751414AbWFIHcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:32:46 -0400
To: akpm@osdl.org
In-Reply-To: <200606090520.k595KvVd032101@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Thu, 08 Jun 2006 22:20:57 -0700

> Add a secmark field to IP and NF conntracks, so that security markings on
> packets can be copied to their associated connections, and also copied back to
> packets as required.  This is similar to the network mark field currently used
> with conntrack, although it is intended for enforcement of security policy
> rather than network policy.
> 
> Signed-off-by: James Morris <jmorris@namei.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.18, thanks.
