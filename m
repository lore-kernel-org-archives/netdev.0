From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] 8139too: use netstats in net_device structure
Date: Mon, 05 May 2008 22:37:24 +0300
Message-ID: <481F61F4.8000809@teltonika.lt>
References: <fvnmeu$jt5$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:33596 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290AbYEEThd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 15:37:33 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jt6V9-0007Gj-9s
	for netdev@vger.kernel.org; Mon, 05 May 2008 19:37:31 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 19:37:31 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 19:37:31 +0000
In-Reply-To: <fvnmeu$jt5$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius Zaleckas wrote:
> Use net_device_stats from net_device structure instead of local.
> Changed airo_read_stats function parameter to net_device.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> 

Sorry. Posted with wrong subject(copy & paste error)...
I will repost it.

