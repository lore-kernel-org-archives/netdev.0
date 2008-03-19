From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 10238] Re: [PATCH] Re: netconsole still hangs
Date: Wed, 19 Mar 2008 14:31:24 -0700 (PDT)
Message-ID: <20080319.143124.67001038.davem@davemloft.net>
References: <20080318224729.GA2760@ami.dom.local>
	<20080319191724.GA2756@ami.dom.local>
	<20080319142010.ed564c39.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl,
	bugme-daemon@bugzilla.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932525AbYCSVbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 17:31:08 -0400
In-Reply-To: <20080319142010.ed564c39.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 19 Mar 2008 14:20:10 -0700

> I'm not sure that we any longer have anything which needs fixing.  Apart
> from merging netpoll-zap_completion_queue-adjust-skb-users-counter.patch?

I'll take care of merging this, give me a day or two.
