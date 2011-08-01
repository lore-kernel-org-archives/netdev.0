From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next v2 00/71] Organize/Move of the Ethernet drivers
 in drivers/net/
Date: Sun, 31 Jul 2011 17:42:30 -0700 (PDT)
Message-ID: <20110731.174230.338842150438671545.davem@davemloft.net>
References: <20110731154515.GA3357@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897Ab1HAAmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2011 20:42:36 -0400
In-Reply-To: <20110731154515.GA3357@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 31 Jul 2011 18:45:16 +0300

>> have tab-completion actually work
> 
> What do you mean?

Try to type a path down into drivers/net/ then try to use TAB
completion to finish the path to some driver file.

It's painful and you have to give it so much context before it'll do
anything that it completely negates the benefits of TAB completion.
