From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] bnx2x: Renaming the "reset_task" to
 "sp_rtnl_task"
Date: Thu, 14 Jul 2011 16:02:41 -0700 (PDT)
Message-ID: <20110714.160241.1297523308149870.davem@davemloft.net>
References: <1310668279.16772.84.camel@lb-tlvb-ariel.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437Ab1GNXCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 19:02:43 -0400
In-Reply-To: <1310668279.16772.84.camel@lb-tlvb-ariel.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Thu, 14 Jul 2011 21:31:19 +0300

>  Renaming the "reset_task" to a more general purpose name,
>  "sp_rtnl_task", as it is already used for another purpose
>  other than reset which is parity recovery, and since I
>  plan to add a third operation for this task, updating the
>  priority to traffic class and traffic class to transmission
>  queues mappings after dcbx negotiation takes place.
>  Signed-off-by: Ariel Elior <ariele@broadcom.com>
>  Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
