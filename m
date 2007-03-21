From: Brice Goglin <brice@myri.com>
Subject: [RESEND 0/4] was: [PATCH 0/3] myri10ge updates for 2.6.21
Date: Wed, 21 Mar 2007 19:43:04 +0100
Message-ID: <46017CB8.3060807@myri.com>
References: <45FDA22E.1070805@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1921 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933452AbXCUSpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 14:45:04 -0400
In-Reply-To: <45FDA22E.1070805@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Hi Jeff,
>
> Here's 3 minor updates for myri10ge in 2.6.21:
> 1. use regular firmware on Serverworks HT2100
> 2. update wcfifo and intr_coal_delay default values
> 3. update driver version to 1.3.0-1.225
>
> Please apply.
>
> Thanks,
> Brice
>   

I just got a last minute fix (management of allocated pages was wrong on
architectures with page size != 4kB. Please drop this serie, I am going
to resend all the patches.

Thanks,
Brice

