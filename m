From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Net-next-2.6 and net-2.6 repos and git-cloning via http
Date: Tue, 15 Dec 2009 20:49:06 +0100
Message-ID: <4B27E832.50700@gmail.com>
References: <b25312890912150204n1ee8e303xe1d165bd90c7c08c@mail.gmail.com> <20091215134243.GA9276@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <roszenrami@gmail.com>, Netdev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:49150 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755221AbZLOTtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 14:49:21 -0500
Received: by fxm21 with SMTP id 21so247677fxm.21
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2009 11:49:18 -0800 (PST)
In-Reply-To: <20091215134243.GA9276@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 12/15/2009 02:42 PM:

> On 15-12-2009 11:04, Rami Rosen wrote:
>> Hello,
>> Do the net-next-2.6 and net-2.6 repossupport git-clone via http (for
>> cases when git port, 9418, is blocked ?)
> 
> David responded a similar question recently - http is not supported.
> 

Hmm... Actually, it's not "reliably" supported only; here is the link:

http://www.spinics.net/lists/netdev/msg110984.html

Jarek P.

> 
>> I am trying:
>> git-clone http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>> Initialized empty Git repository in /home/rami/new/net-next-2.6/.git/
>> fatal: http://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git/info/refs
>> not found: did you run git update-server-info on the server?
>>
>> also:
>> git-clone http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>> Initialized empty Git repository in /home/rami/new/net-next-2.6/.git/
>> gives the same result.
>>
>> (I just want to add that on some other repos, the info/refs does exist,
>> for example, http://www.kernel.org/pub/scm/virt/kvm/pcbios.git/info/refs,
>> and I can do git-clone with
>> http with them, but I really don't know whether this is the reason or
>> just a wild speculation).
>>
>> Rgs,
>> Rami
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


