From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx5: remove dead code
Date: Tue, 31 Dec 2013 18:03:07 +0200
Message-ID: <20131231160306.GA20236@mtldesk30>
References: <20131229135137.7a8566da@nehalam.linuxnetplumber.net>
 <52C15F5A.80601@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Eli Cohen <eli@mellanox.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:47831 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561Ab3LaQDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 11:03:16 -0500
Received: by mail-ee0-f51.google.com with SMTP id b15so5631922eek.10
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 08:03:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52C15F5A.80601@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. I noticed that and will address in the next patch set I plan
to send.

On Mon, Dec 30, 2013 at 03:56:10PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 30-12-2013 1:51, Stephen Hemminger wrote:
> 
> >There are 3 functions in the mlx5 driver which are used and should be
> 
>    s/used/unused/, I think.
> 
> >deleted. Upstream is not the repository to hold old dead code, or code
> >which is used by outside drivers, or code intended for future undetermined
> >features.
> 
> >Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> WBR, Sergei
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
