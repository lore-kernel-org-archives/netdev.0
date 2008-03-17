From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] ioc3.c: replace remaining __FUNCTION__ occurrences
Date: Mon, 17 Mar 2008 08:13:50 -0400
Message-ID: <47DE607E.90300@garzik.org>
References: <20080306155509.GA16365@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Harvey Harrison <harvey.harrison@gmail.com>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52424 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200AbYCQMNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:13:54 -0400
In-Reply-To: <20080306155509.GA16365@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ralf Baechle wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> 
> __FUNCTION__ is gcc-specific, use __func__
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
>  drivers/sn/ioc3.c |   22 +++++++++++-----------
>  1 files changed, 11 insertions(+), 11 deletions(-)

applied


