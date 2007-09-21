From: jamal <hadi@cyberus.ca>
Subject: Re: [LARTC] ifb and ppp
Date: Fri, 21 Sep 2007 08:14:48 -0400
Message-ID: <1190376888.4261.55.camel@localhost>
References: <200709191417.43768.mail@frithjof-hammer.de>
	 <46F25F9A.7010007@trash.net> <1190294388.4734.6.camel@localhost>
	 <200709201600.15202.mail@frithjof-hammer.de>  <46F2910E.9040900@trash.net>
	 <1190373789.4261.16.camel@localhost>  <46F3B16F.1060909@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Frithjof Hammer <mail@frithjof-hammer.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:16444 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbXIUMOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:14:53 -0400
Received: by wr-out-0506.google.com with SMTP id 36so326959wra
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 05:14:53 -0700 (PDT)
In-Reply-To: <46F3B16F.1060909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 13:56 +0200, Patrick McHardy wrote:

> This doesn't help much since he uses the iptables marks for
> classification on the ifb device, so he might as well just
> classify directly using u32. 

true.

> I think it would be nice to
> have an ematch equivalent to the ipt action for matches.

yes, that would help in his case.

> Should be pretty easy to write 
> (slightly above 60 seconds
> according to the documentation :)).

Ah, i hadnt paid attention to that before;-> I'd like to use
that whole thing on a tshirt.

cheers,
jamal

