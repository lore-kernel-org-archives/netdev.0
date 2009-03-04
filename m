From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: some tc commands fail on 2.6.29-rc6-git5, works on 2.6.28.7
Date: Wed, 4 Mar 2009 01:06:59 +0100
Message-ID: <20090304000659.GA4555@ami.dom.local>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com> <20090301165729.8e08e1d7.akpm@linux-foundation.org> <49AC28FF.1040102@gmail.com> <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:40390 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069AbZCDAIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 19:08:31 -0500
Content-Disposition: inline
In-Reply-To: <a5d9929e0903031510r7f173f5cib7bd1a2426e92473@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 11:10:36PM +0000, Joao Correia wrote:
> Hello again
> 
> Sorry for taking so long, been busy with some unexpected work.
> 
> I have checked the .config and can not (to the extent of my not-guru
> knowledge) find anything out of place. Excuse me if its obvious and it
> didnt strike me yet.
...
> [root@duron ~]# tc -V
> tc utility, iproute2-ss090115
...

Joao, you don't need to be sorry at all - on the contrary I'm
extremely sorry! I was so focused on the kernel version but ignored
updating iproute, and it looks like this matters here.

So you're right. Alas I'll not be able to look at it until "tomorrow"
in the evening.

Thanks for the report,
Jarek P.
