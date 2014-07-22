From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] net: Fix recvmmsg timeout handling
Date: Tue, 22 Jul 2014 20:59:40 +0200
Message-ID: <53CEB49C.5050304@gmail.com>
References: <20140721192131.GA3212@kernel.org> <20140721.204538.1952841990990568877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, caitlin.bestler@gmail.com,
	chris.friesen@windriver.com, David.Laight@ACULAB.COM,
	eliedebrauwer@gmail.com, nhorman@tuxdriver.com, neleai@seznam.cz,
	paul@paul-moore.com, remi@remlab.net, steve@chygwyn.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:51434 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaGVTAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 15:00:05 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so973443wiw.0
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 12:00:03 -0700 (PDT)
In-Reply-To: <20140721.204538.1952841990990568877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 05:45 AM, David Miller wrote:
> From: Arnaldo Carvalho de Melo <acme@kernel.org>
> Date: Mon, 21 Jul 2014 16:21:31 -0300
> 
>> 	Trying to get this merged, finally. I has whas has been
>> discussed so far and agreed wrt the timeout handling.
> 
> This gets lots of rejects against the current 'net' tree.
> 
> Please respin and integrate Remi's Acked-by, thanks.
> 

+1 -- then this patch could be tested...

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
