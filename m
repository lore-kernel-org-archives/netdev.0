From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: perf tracepoint hooks
Date: Sun, 07 Feb 2016 14:13:55 -0500 (EST)
Message-ID: <20160207.141355.2029855358220592531.davem@davemloft.net>
References: <cover.1454416592.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.stevens@oracle.com,
	aaron.young@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbcBGTN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:13:59 -0500
In-Reply-To: <cover.1454416592.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue,  2 Feb 2016 10:41:54 -0800

> Added some perf tracepoints to help track and debug sunvnet 
> descriptor state at run-time.

I'm not the biggest fan of putting tracepoints like this in the fast
paths of a networking driver, but what can I say... if they are useful
for you I guess I'm ok with it.

Series applied, thanks.
