From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Wed, 17 Jun 2015 10:37:49 +0100
Message-ID: <1434533869.13744.280.camel@citrix.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
	 <1434533143.13744.273.camel@citrix.com> <55813E3F.8030602@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37686 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbbFQJhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 05:37:52 -0400
In-Reply-To: <55813E3F.8030602@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-17 at 10:30 +0100, Julien Grall wrote:
> I see different opinion on whether using 0x% or %#. As I plan to resend 
> a version with the commit message update, shall I use %#?

I think it's mostly pointless bike-shedding over a saving measured in
single digit bytes, use whichever you like.

Ian.
