From: "Shmulik Ravid" <shmulikr@broadcom.com>
Subject: Re: [PATCH 0/7] Series short description
Date: Sun, 19 Jun 2011 20:58:30 +0300
Message-ID: <1308506310.15528.6.camel@lb-tlvb-shmulik.il.broadcom.com>
References: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4957 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156Ab1FSQIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 12:08:30 -0400
In-Reply-To: <20110617211027.26578.11317.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2011-06-17 at 14:16 -0700, John Fastabend wrote:
> The following series implements improvements to the DCB netlink
> interface. This work was done to improve Application handling
> and support firmware based LLDP agents.
> 
> This adds a multicast group for DCB currently user space has
> trouble keeping in sync across multiple applications and with
> firmware agents making DCB attribute changes in the driver.
> 

I was working on something along the same lines and would like to add on
top of these changes a notification for the CEE flavor.
 


