From: David Miller <davem@davemloft.net>
Subject: Re: qdisc hash table changes...
Date: Tue, 09 Aug 2016 22:04:32 -0700 (PDT)
Message-ID: <20160809.220432.1884446879035612633.davem@davemloft.net>
References: <alpine.LNX.2.00.1608090936180.22028@cbobk.fhfr.pm>
	<20160809.015417.214949723922909511.davem@davemloft.net>
	<alpine.LNX.2.00.1608091101220.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jikos@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932319AbcHJSCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:02:42 -0400
In-Reply-To: <alpine.LNX.2.00.1608091101220.22028@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jikos@kernel.org>
Date: Tue, 9 Aug 2016 11:02:43 +0200 (CEST)

> Does that strictly have to be a show-stopper for the qdisc hash 
> conversion, given the fact that the whole tree is building properly?

I guess not.  Please submit that change as a series, first patches
that correct the build required hash symbol conflict fixes, then
the qdisc change itself.

THanks.
