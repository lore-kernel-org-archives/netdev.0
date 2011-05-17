From: Andi Kleen <andi@firstfloor.org>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 14:48:28 -0700
Message-ID: <m262p9yp5f.fsf@firstfloor.org>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<20110517.174431.1004332995189918916.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:32278 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932496Ab1EQVtA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 17:49:00 -0400
In-Reply-To: <20110517.174431.1004332995189918916.davem@davemloft.net> (David
	Miller's message of "Tue, 17 May 2011 17:44:31 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Guys we can't time out fragments if we are not the final
> destination.

If you're not the final destination you should never even
try to reassemble them?

I'm probably missing something...

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only
