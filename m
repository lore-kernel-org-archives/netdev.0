From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux IPv4 Multicast router?
Date: Wed, 13 Aug 2008 22:26:00 -0700
Message-ID: <48A3C1E8.9090209@candelatech.com>
References: <loom.20080814T011502-799@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Ng <daniel_ng11@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33032 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbYHNF0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 01:26:05 -0400
In-Reply-To: <loom.20080814T011502-799@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Ng wrote:
> Hi,
>
> What is currently the most widely-used IPv4 Multicast Router software in Linux?
>
> Is it mrouted?
>
> If so, is there an active newsgroup for it? The last release I could find (3.9-
> beta3) was made about 10 years ago. Also, the DVMRP RFC spec was never 
> standardised, so I'm not so sure this is the best way to go.
>
> Daniel
>   
I have used Xorp with good results.  It's actively supported on the xorp 
mailing lists
by the developers.

Thanks,
Ben

>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


