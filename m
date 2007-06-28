From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/5 2.6.22-rc6] UDP: Introduce UDP encapsulation type
 for L2TP
Date: Thu, 28 Jun 2007 08:35:42 +0100
Message-ID: <468364CE.1000101@katalix.com>
References: <200706272220.l5RMKc7I004940@quickie.katalix.com> <20070627.153851.42902028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:57259 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755869AbXF1Hfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 03:35:46 -0400
In-Reply-To: <20070627.153851.42902028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> Patch applied, thanks.
> 
> Note that we could use the callback pointer for the XFRM
> case too, and I kind of thought you would understand that
> logical progression and implement that too :-/

I spotted it but didn't want to risk an error that would lead to the 
patch being bounced. Hint taken though. :) I'll implement it if I can 
find some time.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

