From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] bridge fdb dumping takes a filter device
 Dumping a bridge fdb dumps every fdb entry held. With this change we are
 going to filter on selected bridge port.
Date: Thu, 05 Jun 2014 00:15:14 -0700 (PDT)
Message-ID: <20140605.001514.517987695784091540.davem@davemloft.net>
References: <1401623780-4297-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41031 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbaFEHPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 03:15:16 -0400
In-Reply-To: <1401623780-4297-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun,  1 Jun 2014 07:56:19 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Jamal take it easy with the subject lines :-)

The subject line should be as concise, and be formatted as:

[net-next PATCH N/M] ${SUBSYSTEM}: Description.

And "Description." needs to be shorter and more reasonable that what
you supplied here.  Much of that text belongs in the commit message
body instead.

Same goes for patch #2 of this series.
