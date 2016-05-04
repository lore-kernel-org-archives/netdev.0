From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 2/7] gre: Move utility functions to common
 headers
Date: Wed, 04 May 2016 00:53:16 -0400 (EDT)
Message-ID: <20160504.005316.762406965746230352.davem@davemloft.net>
References: <1461975141-954269-1-git-send-email-tom@herbertland.com>
	<1461975141-954269-3-git-send-email-tom@herbertland.com>
	<20160503132944.1951cefb@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbcEDExU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 00:53:20 -0400
In-Reply-To: <20160503132944.1951cefb@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 3 May 2016 13:29:44 +0200

> How do we resolve the conflict between net and net-next? I'd prefer
> gre_parse_header to return the header length. I can submit a patch for
> net-next that does this; that would substantially ease the merge.

Jiri, I just did the net --> net-next merge.  Please send me something on
top of that which does what you like.

Thanks.
