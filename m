From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 14:39:54 -0700 (PDT)
Message-ID: <20070411.143954.101495445.davem@davemloft.net>
References: <461D4DD7.7020207@candelatech.com>
	<20070411.141143.82097512.davem@davemloft.net>
	<461D5394.9040409@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161213AbXDKVjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 17:39:53 -0400
In-Reply-To: <461D5394.9040409@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 11 Apr 2007 14:31:00 -0700

> I've spent solid weeks tracking down obscure races.

I've spent solid weeks tracking down kernel stack corruption and scsi
problems on sparc64, as well as attending to my network maintainer
duties, what is your point?

> I'm hoping that someone who knows the tcp stack will have some idea
> of places to look based on the reported symptoms so that I don't
> have to spend another solid week chasing this one.

If you can reproduce the bug and others cannot, you are the one in the
best possible situation to add diagnostics and figure out what's
wrong.  Please do this.

You get a lot from Linux in your work, but you sure grumble a lot when
you might need to give even a smidgen back.  You just dump random
pieces of information at this list and expect other people to just fix
it for you.  It's this part of your attitude that I absolutely do not
like.  Other people are able to report bugs in a pleasant and
non-selfish way that makes me want to go and fix the bug for them
proactively, you do not.
