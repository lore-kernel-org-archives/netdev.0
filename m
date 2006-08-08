From: David Miller <davem@davemloft.net>
Subject: Re: remove is_setbyuser patch
Date: Tue, 08 Aug 2006 00:56:37 -0700 (PDT)
Message-ID: <20060808.005637.124551821.davem@davemloft.net>
References: <20060808080231.GB13512@prozac>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18123
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932262AbWHHH4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 03:56:34 -0400
To: louis.nyffenegger@gmail.com
In-Reply-To: <20060808080231.GB13512@prozac>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: louis.nyffenegger@gmail.com
Date: Tue, 8 Aug 2006 10:02:31 +0200

> The same without gmail problems
> 
> == Changelog ==
> 
> The value is_setbyuser from struct ip_options is never used and set
> only one time (http://linux-net.osdl.org/index.php/TODO#IPV4).
> This little patch removes it from the kernel source.
> 
> Signed-off-by: Louis Nyffenegger <louis.nyffenegger@gmail.com>

Applied, thanks a lot.
