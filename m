From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-mm2
Date: Sat, 30 Sep 2006 12:53:42 -0700
Message-ID: <20060930125342.036aab26.akpm@osdl.org>
References: <20060928014623.ccc9b885.akpm@osdl.org>
	<20060930133706.GA3291@melchior.yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31720 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751798AbWI3Txr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 15:53:47 -0400
To: Tobias Diedrich <ranma@tdiedrich.de>
In-Reply-To: <20060930133706.GA3291@melchior.yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Sep 2006 15:37:06 +0200
Tobias Diedrich <ranma@tdiedrich.de> wrote:

> Andrew Morton wrote:
> 
> > - More updates to the MSI code.  If your machine has Message Signalled
> >   Interrupts, please enable it and give it a try.
> 
> I'm happy to report, that with 2.6.18-mm2 suspend to disk works for
> me without additional patches, tested both with MSI interrupts
> disabled and enabled (forcedeth driver).

Thanks.

Which kernel version(s) didn't work?  -mm1?  Mainline?
