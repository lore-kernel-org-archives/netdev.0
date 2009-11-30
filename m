From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: Remove duplicate type definitions
Date: Mon, 30 Nov 2009 08:30:35 -0500
Message-ID: <4B13C8FB.1060002@garzik.org>
References: <1259509242.3709.69.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?QW7DrWJhbCBNb25zYWx2ZSBTYWxhemFy?= <anibal@debian.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50303 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752294AbZK3Nag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 08:30:36 -0500
In-Reply-To: <1259509242.3709.69.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2009 10:40 AM, Ben Hutchings wrote:
> <linux/ethtool.h>  and ethtool-copy.h now include<linux/types.h>, which
> provides these type definitions.
>
> The duplicate type definitions in ethtool-util.h conflict with those in
> <asm/types.h>  on Alpha, as reported in<http://bugs.debian.org/545850>.
>
> Signed-off-by: Ben Hutchings<ben@decadent.org.uk>

applied


