From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH] Update function names in /proc/net/tcp documentation
Date: Sun, 14 Oct 2007 11:59:34 +0200
Message-ID: <20071014115934.13530a8a@hyperion.delvare>
References: <20071013144300.08128901@hyperion.delvare>
	<E1IggRI-0001Zc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-100-sunday.noc.nerim.net ([62.4.17.100]:3355 "EHLO
	mallaury.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755110AbXJNJ7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 05:59:38 -0400
In-Reply-To: <E1IggRI-0001Zc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

On Sat, 13 Oct 2007 20:49:56 +0800, Herbert Xu wrote:
> Jean Delvare <khali@linux-fr.org> wrote:
> >
> > I didn't know that, sorry. What is the new interface to access the
> > TCP information?
> 
> inet_diag is the preferred interface.

How does it work? Is there some documentation available? I see
net/ipv4/inet_diag.c but I have no idea how to use it.

Thanks,
-- 
Jean Delvare
