From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use SYSCALL_DEFINEx for sys_recv
Date: Wed, 16 Apr 2014 15:15:26 -0400 (EDT)
Message-ID: <20140416.151526.2089362173425552177.davem@davemloft.net>
References: <1397633568-26464-1-git-send-email-jan.glauber@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jan.glauber@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbaDPTP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:15:27 -0400
In-Reply-To: <1397633568-26464-1-git-send-email-jan.glauber@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Glauber <jan.glauber@gmail.com>
Date: Wed, 16 Apr 2014 09:32:48 +0200

> Make sys_recv a first class citizen by using the SYSCALL_DEFINEx
> macro. Besides being cleaner this will also generate meta data
> for the system call so tracing tools like ftrace or LTTng can
> resolve this system call.
> 
> Signed-off-by: Jan Glauber <jan.glauber@gmail.com>

Applied, thanks.
