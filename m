From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/7] net: make TCP preemptible
Date: Fri, 29 Apr 2016 13:53:15 -0700
Message-ID: <1461963195.5535.158.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com>
	 <20160429.163958.6363647244164609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, soheil@google.com,
	ast@fb.com, marcelo.leitner@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:33158 "EHLO
	mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbcD2UxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:53:19 -0400
Received: by mail-vk0-f44.google.com with SMTP id o133so5296515vka.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 13:53:18 -0700 (PDT)
In-Reply-To: <20160429.163958.6363647244164609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-29 at 16:39 -0400, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Thu, 28 Apr 2016 20:10:42 -0700
> 
> > Most of TCP stack assumed it was running from BH handler.
> 
> Assuming you are respinning this to fix that stats bumping typo.
> 
> You should really look into how that got corrupted. :)
> 

I had corruptions issues and a dying HDD one month ago.

I have a brand new HDD, but maybe the SSD I use for my git trees is
dying as well :(

But I've seen this strange patterns in the past, it might be the old
text editor I am using.

I filed a bug for it, it might be the time to compile it on 64bit ;)

$ m -V
	6.30 [18 Mai 2000]
	Compile par GNUC version 2.95.2 19991024 (release) Date May 18 2000
Heure 23:48:40
Usage:      m [-VR] [-c fic] [+ligne] [file1 file2 ...]


I don't remember I edited this file after the git format-patch,
but then it is Friday afternoon ;)

Thanks
