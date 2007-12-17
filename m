From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: net-2.6.25 rebased...
Date: Mon, 17 Dec 2007 12:20:21 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712171210190.20530@kivilampi-30.cs.helsinki.fi>
References: <20071216.162101.209866976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56405 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762820AbXLQKUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 05:20:24 -0500
In-Reply-To: <20071216.162101.209866976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007, David Miller wrote:

> I needed to rebase for two reasons:
> 
> 1) Ilpo asked me to revert a lot of TCP stuff and the
>    easiest way to do that was during a rebase.
> 
> 2) Patrick McHardy needs some of the pending net-2.6
>    bug fixes in there in order to send me patches
>    for some netfilter compat stuff.
> 
> It's all there in the usual spot:
> 
> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.25.git
> 
> I'm still doing build tests with various configurations on my
> Niagara-2 box.
> 
> Let me know if I screwed up anything, thanks!

Thanks, at least the end result for TCP was exactly what I 
expected to find there...


-- 
 i.
