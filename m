From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] tcp: IPv6 support for fastopen server
Date: Sun, 11 May 2014 23:33:04 -0400 (EDT)
Message-ID: <20140511.233304.404648412910391761.davem@davemloft.net>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
	<CAK6E8=dR0MrRtwi=LtihoHXXxbynao8C9mAYc29riVdP6--6TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, longinus00@gmail.com,
	hkchu@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbaELDdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:33:07 -0400
In-Reply-To: <CAK6E8=dR0MrRtwi=LtihoHXXxbynao8C9mAYc29riVdP6--6TA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Sun, 11 May 2014 20:26:21 -0700

> Sorry I forget to mention the patches are for net-next. Let me know if
> I should re-submit with the proper subject line.

That's not necessary.

And you might as well not do so for another reason, for the past few
days any time a googler posts to vger.kernel.org from their work
address, every list recipient that forwards their email to gmail
ends up bouncing with stuff like:

<xxxx@gmail.com> (expanded from <x@yyy.org.whatever>): host
    gmail-smtp-in.l.google.com[74.125.25.26] said: 550-5.7.1 [xxx.xx.xxx.xxx
    1] Our system has detected an unusual rate of 550-5.7.1 unsolicited mail
    originating from your IP address. To protect our 550-5.7.1 users from spam,
    mail sent from your IP address has been blocked. 550-5.7.1 Please visit
    550-5.7.1 http://www.google.com/mail/help/bulk_mail.html to review our Bulk
    550 5.7.1 Email Senders Guidelines. fb11si8629921pac.227 - gsmtp (in reply
    to end of DATA command)
