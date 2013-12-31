From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] mlx5: remove dead code
Date: Tue, 31 Dec 2013 21:45:55 +0300
Message-ID: <52C310E3.8070401@cogentembedded.com>
References: <20131229135137.7a8566da@nehalam.linuxnetplumber.net> <52C15F5A.80601@cogentembedded.com> <20131231160306.GA20236@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>,
	Eli Cohen <eli@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:52086 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843Ab3LaRp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 12:45:59 -0500
Received: by mail-la0-f43.google.com with SMTP id n7so6332044lam.16
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 09:45:57 -0800 (PST)
In-Reply-To: <20131231160306.GA20236@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/31/2013 07:03 PM, Eli Cohen wrote:

> Thanks. I noticed that and will address in the next patch set I plan
> to send.

    Noticed what? Unused functions? They were removed by Stephen, not me.

>>> There are 3 functions in the mlx5 driver which are used and should be

>>     s/used/unused/, I think.

>>> deleted. Upstream is not the repository to hold old dead code, or code
>>> which is used by outside drivers, or code intended for future undetermined
>>> features.

>>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

WBR, Sergei
