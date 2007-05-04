From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/40] Swap over Networked storage -v12
Date: Fri, 04 May 2007 13:02:39 -0700 (PDT)
Message-ID: <20070504.130239.38710262.davem@davemloft.net>
References: <20070504102651.923946304@chello.nl>
	<20070504.122716.31641374.davem@davemloft.net>
	<1178307709.2767.19.camel@lappy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no, tgraf@suug.ch,
	James.Bottomley@SteelEye.com, michaelc@cs.wisc.edu,
	akpm@linux-foundation.org, phillips@google.com
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031393AbXEDUCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 16:02:52 -0400
In-Reply-To: <1178307709.2767.19.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 04 May 2007 21:41:49 +0200

> How would you prefer I present these?

How about 8 or 9 at a time?  You are building infrastructure
and therefore you could post them 1 at a time for review
since each patch should be able to stand on it's own.
