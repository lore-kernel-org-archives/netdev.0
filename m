From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 15582] New: BUG: unable to handle kernel NULL pointer
 dereference at 0000000000000028
Date: Tue, 23 Mar 2010 12:40:17 -0700 (PDT)
Message-ID: <20100323.124017.200119329.davem@davemloft.net>
References: <20100322161416.c4b369f9.akpm@linux-foundation.org>
	<20100322.210043.66718554.davem@davemloft.net>
	<80769D7B14936844A23C0C43D9FBCF0F254E49A854@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, kaber@trash.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	stivi@kity.pl
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751554Ab0CWTjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 15:39:55 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F254E49A854@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Tue, 23 Mar 2010 11:32:19 -0700

> The patch below should address it.  However I suspect it will get
> mangled by our email system here so I don't believe it will apply.
> I have also sent a copy of to Jeff to pull into his tree for testing
> and submission.

Good spotting, thanks Alex.

I'll wait for testing and a final version via Jeff.
