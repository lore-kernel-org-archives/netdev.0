From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 01/12] l2tp: make local function static
Date: Thu, 21 Oct 2010 21:30:15 +0100
Message-ID: <4CC0A2D7.50900@katalix.com>
References: <20101021175045.625707607@vyatta.com> <20101021175148.018298774@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:52664 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757353Ab0JUUaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 16:30:17 -0400
In-Reply-To: <20101021175148.018298774@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/2010 18:50, Stephen Hemminger wrote:
> Also moved the refcound inlines from l2tp_core.h to l2tp_core.c
> since only used in that one file.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 

Acked-by: James Chapman <jchapman@katalix.com>


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

