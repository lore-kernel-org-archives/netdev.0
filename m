From: Roland Dreier <rdreier@cisco.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Tue, 17 Apr 2007 08:58:47 -0700
Message-ID: <ada1wij56x4.fsf@cisco.com>
References: <20070402014319.GA8345@zip.com.au>
	<20070402001300.3b66007d.akpm@linux-foundation.org>
	<20070402074108.GB8345@zip.com.au> <1176596401.5847.7.camel@dell>
	<1176750651.6217.3.camel@dell> <20070416234348.GF8345@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jean-Daniel Pauget <jd@disjunkt.com>
To: CaT <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:15212 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031103AbXDQP6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 11:58:52 -0400
In-Reply-To: <20070416234348.GF8345@zip.com.au> (cat@zip.com.au's message of "Tue, 17 Apr 2007 09:43:48 +1000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I actually have a couple of Dell 1950 systems with bnx2 NICs too,
which I use for kernel development (ie one more crash is fine :)

If someone can give me an idea for what kind of load to use, I can try
this patch out to see if it triggers.

 - R.
