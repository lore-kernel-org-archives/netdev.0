From: David Miller <davem@davemloft.net>
Subject: Re: [patch 8/9] [PATCH] kmsg: convert claw printk messages to kmsg
 api.
Date: Tue, 24 Mar 2009 15:28:50 -0700 (PDT)
Message-ID: <20090324.152850.127356060.davem@davemloft.net>
References: <20090324132742.300929000@linux.vnet.ibm.com>
	<20090324133049.771837000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	richtera@us.ibm.com
To: ursula.braun@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53090
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753391AbZCXW3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 18:29:04 -0400
In-Reply-To: <20090324133049.771837000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>
Date: Tue, 24 Mar 2009 14:27:50 +0100

> From: Andy Richter <richtera@us.ibm.com>
> 
> Signed-off-by: Andy Richter <richtera@us.ibm.com>
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>

This patch was already added to net-next-2.6 on January 20th:

commit 4811fcb79cee80c683237cfd15ca214e1d78c548
Author: Andy Richter <richtera@us.ibm.com>
Date:   Tue Jan 20 06:14:33 2009 +0000

    kmsg: convert claw printk messages
    
    claw printks are converted to dev_xxx and pr_xxx macros.
    
    Signed-off-by: Andy Richter <richtera@us.ibm.com>
    Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

