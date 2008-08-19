From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Tue, 19 Aug 2008 00:03:36 -0700 (PDT)
Message-ID: <20080819.000336.199570743.davem@davemloft.net>
References: <20080818113531.GB7158@ff.dom.local>
	<20080818.205427.140031432.davem@davemloft.net>
	<20080819065958.GB4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56803
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751827AbYHSHDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:03:37 -0400
In-Reply-To: <20080819065958.GB4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 19 Aug 2008 06:59:58 +0000

> I guess, we currently don't need this. At least ingress checks and
> skipps acting for &noop_qdisc. I'd prefer to see some lockdep warning
> first, or maybe you could show some scenario?

No, I don't, good point.  Let's leave this for now.
