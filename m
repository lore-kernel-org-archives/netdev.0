From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection
 opening
Date: Wed, 08 Oct 2008 11:21:33 -0700 (PDT)
Message-ID: <20081008.112133.226941794.davem@davemloft.net>
References: <20081008081109.GA25342@1wt.eu>
	<20081008.094212.130684373.davem@davemloft.net>
	<20081008170739.GA546@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49116
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752974AbYJHSV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 14:21:58 -0400
In-Reply-To: <20081008170739.GA546@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Wed, 8 Oct 2008 19:07:39 +0200

> On Wed, Oct 08, 2008 at 09:42:12AM -0700, David Miller wrote:
> > and that's a good argument to not apply "yet another random knob"
> > to the kernel.
> 
> OK for the random knob. If you feel comfortable with a patch to simply remove
> the feature, I can send you such a patch too.

If I don't want the knob, what makes you think I'll accept a patch to
remove or ifdef the code?

I absolutely will not.
