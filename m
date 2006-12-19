From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Mon, 18 Dec 2006 18:13:54 -0800 (PST)
Message-ID: <20061218.181354.28800773.davem@davemloft.net>
References: <1166492725.3180.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49669
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932647AbWLSCOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 21:14:19 -0500
To: lyw@nanjing-fnst.com
In-Reply-To: <1166492725.3180.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Yewang <lyw@nanjing-fnst.com>
Date: Tue, 19 Dec 2006 09:45:25 +0800

> David Miller <davem@davemloft.net> wrote:
> 
> > Applied, but I had to fix many errors in your patch by hand.
> > Please take care of these details next time.
> > 
> > Here, your email client wrapped the lines in the patch, corrupting it.
> > 
> > Please use real tab characters, when necessary, in the indentation of
> > new code lines that you add, not just spaces.
> > 
> > Thank you.
> 
> Mr David Miller
> 
> I have made another patch file about the ip_rt_send_redirect().
> This patch has not wrapped lines, and can be patched into the kernel.
> 
> Following is my patch:
> 
> signed-off-by: Li Yewang <lyw@nanjing-fnst.com>

I said I already fixed the patch up for you when I applied
it, you didn't need to redo it.
