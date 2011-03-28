From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Make some local functions static
Date: Sun, 27 Mar 2011 18:16:03 -0700 (PDT)
Message-ID: <20110327.181603.246526652.davem@davemloft.net>
References: <4D89CFE7.4050907@freyther.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: holger@freyther.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553Ab1C1BQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:16:41 -0400
In-Reply-To: <4D89CFE7.4050907@freyther.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Hans Peter Freyther <holger@freyther.de>
Date: Wed, 23 Mar 2011 11:48:07 +0100

> @@ -132,8 +132,8 @@ void  sctp_init_cause(struct sctp_chunk *chunk, __be16
> cause_code,

Your patches are corrupted by your email client, in particular it has
chopped up long lines.

Please fix your email setup, test it out by emailing both of your SCTP
patches to yourself, then try to apply the patches in the emails you
receive.

Then you can freshly resubmit them here.

Thank you.
