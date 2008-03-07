From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [NET] ioc3.c: replace remaining __FUNCTION__ occurrences
Date: Fri, 7 Mar 2008 00:17:52 -0800
Message-ID: <20080307001752.09a8b291.akpm@linux-foundation.org>
References: <20080306155509.GA16365@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Harvey Harrison <harvey.harrison@gmail.com>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39878 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752219AbYCGISg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 03:18:36 -0500
In-Reply-To: <20080306155509.GA16365@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Mar 2008 15:55:09 +0000 Ralf Baechle <ralf@linux-mips.org> wrote:

> From: Harvey Harrison <harvey.harrison@gmail.com>
> 
> __FUNCTION__ is gcc-specific, use __func__
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
>
>  drivers/sn/ioc3.c |   22 +++++++++++-----------

this isn't a net driver is it?

I already had it queued - I'll add your acked-by ;)
