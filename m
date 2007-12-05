From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: [PATCH] correct typo in __xfrm4_bundle_create()
Date: Wed, 5 Dec 2007 16:33:56 +0200
Message-ID: <d0383f90712050633q5dadf8dbxa357a7d50f54528d@mail.gmail.com>
References: <d0383f90712050541p5d8ffce6q8748d7c6b66ea9c6@mail.gmail.com>
	 <20071205.054711.186439758.davem@davemloft.net>
	 <d0383f90712050559o7ad78dbbm51f74984b591e66d@mail.gmail.com>
	 <20071205.060316.74563693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:1623 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbXLEOeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 09:34:06 -0500
Received: by py-out-1112.google.com with SMTP id u77so107233pyb
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2007 06:33:57 -0800 (PST)
In-Reply-To: <20071205.060316.74563693.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Sorry, but I had tried several times from 3 machines (without
iptables/SELinux)  and git-clone
gives "Connection refused" error.

git-clone git://kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git 2.6.25

Initialized empty Git repository in /work/src/2.6.25/.git/
fatal: unable to connect a socket (Connection refused)
fetch-pack from
'git://kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git'
failed.
Ian


On Dec 5, 2007 4:03 PM, David Miller <davem@davemloft.net> wrote:
> From: "Ian Brown" <ianbrn@gmail.com>
> Date: Wed, 5 Dec 2007 15:59:52 +0200
>
> > Hello,
> > Sorry ; but is this tree can be fetched ? it requires a password.
> >
> > I try:
> > git-clone kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.25.git net-2.6.25
> > and get:
> > root@kernel.org's password:
>
> Use the git:// URL prefix.
>
