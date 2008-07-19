From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: READ ME, net-2.6 fully merged
Date: Sat, 19 Jul 2008 09:50:36 +0200
Message-ID: <48819CCC.8070800@gmail.com>
References: <20080718.033947.193705552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:57341 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbYGSHta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 03:49:30 -0400
Received: by fg-out-1718.google.com with SMTP id 19so283740fgg.17
        for <netdev@vger.kernel.org>; Sat, 19 Jul 2008 00:49:28 -0700 (PDT)
In-Reply-To: <20080718.033947.193705552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 07/18/2008 12:39 PM:

> I merged Linus's current tree into net-next-2.6, fixed up all
> the merge conflicts, and pushed this out as plain "net-2.6":
> 
> 	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
> 
> There is a net-next-2.6 still there, but it's just a plain clone
> of Linus's tree so that the linux-next folks can still do dummy
> pulls from it.

A little btw. question: I know you are busy now with more serious
problems and it's not for now, but: after the last net-next-2.6 git
policy change most of the time neither net-2.6 nor net-next-2.6
could be treated as current net state. I tried to stick to net-next,
but it was idle most of the time.

Isn't it possible to create the third git tree maintained the old
net-next way i.e. net-next-2.6 with immediate bug fixes from net-2.6
(and of course rebased from time to time)? I guess you could be doing
something like this privately, so it's not necessarily a lot of
additional hassle?

Thanks,
Jarek P.
