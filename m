From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 patch 1/1][SCHED] remove unused variable skb in
 dev_deactivate_queue function
Date: Mon, 21 Jul 2008 09:18:51 -0700 (PDT)
Message-ID: <20080721.091851.160566899.davem@davemloft.net>
References: <4884B2DB.2000403@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751888AbYGUQSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:18:51 -0400
In-Reply-To: <4884B2DB.2000403@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Mon, 21 Jul 2008 18:01:31 +0200

> [SCHED] remove unused variable skb in dev_deactivate_queue function
> 
> Removed unused variable 'skb' in the dev_deactivate_queue function
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks Daniel.

Please use "subsystem_in_lowercase: Foo bar baz." format for
commit header lines in the future.

Thanks again.
