From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/2] lwtunnel: change prototype of lwtunnel_state_get()
Date: Fri, 24 Jul 2015 06:53:10 -0700
Message-ID: <55B24346.4070504@cumulusnetworks.com>
References: <1437733716-4494-1-git-send-email-nicolas.dichtel@6wind.com> <1437733716-4494-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:33232 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbbGXNxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 09:53:13 -0400
Received: by pdbnt7 with SMTP id nt7so14179823pdb.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 06:53:12 -0700 (PDT)
In-Reply-To: <1437733716-4494-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/15, 3:28 AM, Nicolas Dichtel wrote:
> It saves some lines and simplify a bit the code when the state is returning
> by this function. It's also useful to handle a NULL entry.
>
> To avoid too long lines, I've also renamed lwtunnel_state_get() and
> lwtunnel_state_put() to lwtstate_get() and lwtstate_put().
>
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

thanks.
