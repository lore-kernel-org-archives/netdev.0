From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: Linux IPv4 Multicast router?
Date: Thu, 14 Aug 2008 08:44:36 +0300
Message-ID: <b25312890808132244r11088c87kd6be7bf22bbc2dfc@mail.gmail.com>
References: <loom.20080814T011502-799@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Daniel Ng" <daniel_ng11@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:60542 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbYHNFoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 01:44:37 -0400
Received: by gxk9 with SMTP id 9so1964845gxk.13
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 22:44:36 -0700 (PDT)
In-Reply-To: <loom.20080814T011502-799@post.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Consider using xorp:
http://www.xorp.org/

It was OK  for me with IPv6 and I believe that it is may also OK for
IPV4 ;I had tried it with IPv6 Multicast Routing
( Yoshfuji git patches, following Mickael Hoerdt work,
which were integrated some months ago in the net 2.6 tree).

Regards,
Rami Rosen





On Thu, Aug 14, 2008 at 4:21 AM, Daniel Ng <daniel_ng11@lycos.com> wrote:
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
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
