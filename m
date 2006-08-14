From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: airo: inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
Date: Mon, 14 Aug 2006 13:09:31 +0300
Message-ID: <20060814100931.GA2373@ee.oulu.fi>
References: <20060808094410.GA29313@ee.oulu.fi> <E1GAPZF-0003w4-00@gondolin.me.apana.org.au> <20060808113851.GA17861@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:34243 "EHLO ee.oulu.fi")
	by vger.kernel.org with ESMTP id S932170AbWHNKJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 06:09:49 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060808113851.GA17861@ee.oulu.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 02:38:51PM +0300, Pekka Pietikainen wrote:
> Hmm... I retried with a 2.6.18rc4-based rawhide kernel and the warning
> is still there, previous one was rc3-git7.
> 
> Could be http://marc.theaimsgroup.com/?l=linux-netdev&m=115461336523555&w=2
> which isn't upstream yet, right?
The warning is gone in the rawhide kernel-of-the-day and
everything seems happy now, so whatever it was, it's fixed now.



