From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V7 3/8] posix clocks: introduce dynamic clocks
Date: Fri, 17 Dec 2010 07:29:33 +0100
Message-ID: <20101217062933.GA2982@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <8debe4d48d9a6484b7fbd35d8888524155fed977.1292512461.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1012161939340.12146@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:52043 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab0LQG3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 01:29:40 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1012161939340.12146@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 09:56:38PM +0100, Thomas Gleixner wrote:
> > +void *posix_clock_private(struct file *fp);
> 
> Leftover ? There is neither a caller nor an implementation

Yes, you are right. Sorry.

This patch series has been through several contortions, and this
current one won't be the last!

As to the other comments, thanks for your careful review. I will adapt
the patch set accordingly.

Richard
