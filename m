From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] sunvnet: Reduce LDC message overhead.
Date: Thu, 04 Sep 2014 22:37:24 -0700 (PDT)
Message-ID: <20140904.223724.206826043871814498.davem@davemloft.net>
References: <20140902161936.GA31516@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbaIEFhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:37:25 -0400
In-Reply-To: <20140902161936.GA31516@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 2 Sep 2014 12:19:36 -0400

> This patchset has an updated version of the v1 changes to reduce the
> overhead from LDC messages. 

Let's hold on these changes until the memory barrier issues brought up
by David is resolved.
