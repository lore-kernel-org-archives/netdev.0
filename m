From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: fix incorrect initializer in union
 vxlan_addr
Date: Thu, 21 Aug 2014 21:27:08 -0700 (PDT)
Message-ID: <20140821.212708.2127029655910110294.davem@davemloft.net>
References: <53EDCCFE.5090301@linux.vnet.ibm.com>
	<20140818.101143.2274310300741627370.davem@davemloft.net>
	<53F3B55B.6070505@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gstenzel@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbaHVE1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 00:27:09 -0400
In-Reply-To: <53F3B55B.6070505@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerhard Stenzel <gstenzel@linux.vnet.ibm.com>
Date: Tue, 19 Aug 2014 22:36:43 +0200

> Trying again ... 

This is not the correct way to resubmit a patch properly.

Do not ever submit a new copy of a patch as a reply to a discussion
thread, quoting unrelated material, etc.

Instead, make a new, fresh, mailing list posting as if you were
posting the patch for the first time.  Except you add
"[PATCH v2 net]" or similar to indicate this is a new submission
of the patch.
