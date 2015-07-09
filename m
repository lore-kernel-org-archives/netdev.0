From: David Miller <davem@davemloft.net>
Subject: Re: net-next is OPEN
Date: Thu, 09 Jul 2015 11:05:17 -0700 (PDT)
Message-ID: <20150709.110517.1746707542010833297.davem@davemloft.net>
References: <559E5FCE.6010301@cogentembedded.com>
	<20150709.104019.370940061164391476.davem@davemloft.net>
	<559EB3F4.3060000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850AbbGISFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 14:05:18 -0400
In-Reply-To: <559EB3F4.3060000@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 09 Jul 2015 20:48:36 +0300

>    I then don't quite understand why you close net-next during the
>    merge window and beyond.

Because when 1700+ changes are committed from us to Linus's tree we
should be focused on fixing regressions and fallout from that rather
than reviewing new features.

Plus, frankly, I'm exhausted during the merge window, and the last
thing I need is a backlog of several hundred patches targetting
net-next to worry about.
