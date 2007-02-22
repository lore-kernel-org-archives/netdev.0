From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: Re: [PATCH 1/2][TCP] YeAH-TCP: algorithm implementation
Date: Thu, 22 Feb 2007 17:10:05 +0100
Message-ID: <8dd26e70702220810x21c8d494u1200de1c02d23d57@mail.gmail.com>
References: <45D97C62.5070406@gmail.com>
	 <20070222.001918.55725416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco@net.infocom.uniroma1.it,
	andrea.baiocchi@uniroma1.it
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:56813 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbXBVQKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 11:10:07 -0500
Received: by nf-out-0910.google.com with SMTP id o25so568523nfa
        for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 08:10:05 -0800 (PST)
In-Reply-To: <20070222.001918.55725416.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, I'll check for formatting errors in the future.

2007/2/22, David Miller <davem@davemloft.net>:
> Applied to tcp-2.6 GIT, there were a lot of broken whitespace
> issues in your patch, GIT makes mention of them quite happily
> even without applying the patch, which I recommend you do in the
> future so I don't have to fix up your patches.  The command I
> use (best with 1.5.0 GIT) is:
>
>         git apply --check --whitespace=error-all file.patch
>
> Thanks.
>
