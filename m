From: David Miller <davem@davemloft.net>
Subject: Re: remove is_setbyuser patch
Date: Tue, 08 Aug 2006 00:12:20 -0700 (PDT)
Message-ID: <20060808.001220.79431401.davem@davemloft.net>
References: <860a3e3d0608080002i3715402bw330810a07e10b35c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3979
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932505AbWHHHMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 03:12:17 -0400
To: louis.nyffenegger@gmail.com
In-Reply-To: <860a3e3d0608080002i3715402bw330810a07e10b35c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Louis Nyffenegger" <louis.nyffenegger@gmail.com>
Date: Tue, 8 Aug 2006 09:02:44 +0200

> == Changelog ==
> 
> The value is_setbyuser from struct ip_options is never used and set
> only one time (http://linux-net.osdl.org/index.php/TODO#IPV4).
> This little patch removes it from the kernel source.
> 
> Signed-off-by: Louis Nyffenegger <louis.nyffenegger@gmail.com>
> 
> == Patch ==

GMAIL has corrupted your patch by changing tab characters into
spaces, among other things.

This makes your patch unusable.

Please resend the patch after configuring your email account
to not corrupt ASCII text on outgoing emails.
