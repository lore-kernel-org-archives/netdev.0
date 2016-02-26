From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 3/3] net: convert tc_u32 to use the intermediate
 representation
Date: Fri, 26 Feb 2016 12:34:52 -0500 (EST)
Message-ID: <20160226.123452.1302145219271715730.davem@davemloft.net>
References: <56CF6612.6040900@gmail.com>
	<20160226142402.GB2523@salvia>
	<56D066D7.2090708@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org, jiri@resnulli.us,
	horms@verge.net.au
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981AbcBZRey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 12:34:54 -0500
In-Reply-To: <56D066D7.2090708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 26 Feb 2016 06:53:11 -0800

> sure but its easier for me to just consume u32 at the moment. And I
> am concerned about performance overhead with this IR. I'm going to need
> to have a performant solution eventually and I don't like converting
> into one IR only to go into another.

+1
