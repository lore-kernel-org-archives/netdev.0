From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/9] secmark: Add new flask definitions to SELinux
Date: Fri, 09 Jun 2006 00:27:46 -0700 (PDT)
Message-ID: <20060609.002746.112853434.davem@davemloft.net>
References: <200606090520.k595KsJD032089@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5536
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751403AbWFIH2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:28:32 -0400
To: akpm@osdl.org
In-Reply-To: <200606090520.k595KsJD032089@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Thu, 08 Jun 2006 22:20:54 -0700

> This patch:
> 
> Add support for a new object class ('packet'), and associated permissions
> ('send', 'recv', 'relabelto').  These are used to enforce security policy for
> network packets labeled with SECMARK, and for adding labeling rules.
> 
> Signed-off-by: James Morris <jmorris@namei.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.18, thanks.
