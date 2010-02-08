From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PROBLEM: oops w/ bridge in 2.6.32.7
Date: Mon, 8 Feb 2010 15:47:35 -0800
Message-ID: <20100208154735.1d60f43c@nehalam>
References: <20100206165351.GA9411@localhost>
	<20100208142044.6be97024.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml@Think-Future.de,
	Linux Kernel-Liste <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50146 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134Ab0BHXrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 18:47:47 -0500
In-Reply-To: <20100208142044.6be97024.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Feb 2010 14:20:44 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > virtualbox-ose              3.1.2-dfsg-1+b1
> > virtualbox-ose-source       3.1.2-dfsg-1
> > 


Sorry, since virtualbox is not part of standard mainline kernel,
I suspect the problem is there.
Please reproduce with standard 2.6.32.X distribution.
