From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 08:42:39 +0100
Message-ID: <20080201074239.GA2897@ff.dom.local>
References: <47A2540D.8090003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:48892 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933253AbYBAHfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 02:35:39 -0500
Received: by ug-out-1314.google.com with SMTP id z38so709202ugc.16
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 23:35:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47A2540D.8090003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01-02-2008 00:04, Jarek Poplawski wrote:
...
> ...On the other hand, with this DSL argument from the sub-thread you
> could be quite right: if this "everyone" wants to use one NIC for
> both high speed local network and such a DSL, then learning ethtool
> could be not enough...

...But, on the other hand, in this case the realization seems to be
wrong: probably still all locally created packets will be treated
the same - or I miss something?

Jarek P.
