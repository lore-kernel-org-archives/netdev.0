From: jamal <hadi@cyberus.ca>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP
 packets
Date: Sun, 10 Jan 2010 11:03:57 -0500
Message-ID: <1263139437.11273.13.camel@bigi>
References: <bug-14837-10286@http.bugzilla.kernel.org/>
	 <20091218153209.45042a58.akpm@linux-foundation.org>
	 <1261227303.11973.2.camel@bigi>  <4B2ECCAB.8010702@free.fr>
	 <1261422543.8201.6.camel@bigi>  <4B45EFF3.50006@free.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Benoit PAPILLAULT <benoit.papillault@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:43948 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab0AJQD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 11:03:59 -0500
Received: by qw-out-2122.google.com with SMTP id 8so2949996qwh.37
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 08:03:59 -0800 (PST)
In-Reply-To: <4B45EFF3.50006@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salut Benoit,

I didnt see any patch...

Also did you try changing the mtu per suggestion i made?
People tend to be busy and sometimes dont read the mailing list. To
get proper answers, always CC the maintainers. In this case CC Stephen
Hemminger - he maintains the bridging code. I am ccing Herbert Xu as
well - he may have opinions on the gre side of things. My suggestion is
you repost your issue along with your patch and describe why it solves
your problem.

cheers,
jamal

On Thu, 2010-01-07 at 15:30 +0100, Benoit PAPILLAULT wrote:
> First of all, my best wishes for year 2010!
> 
> Any comments on the patch I sent? Should I send it on a mailing list for 
> a broader audience?
> 
> Regards,
> Benoit
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

