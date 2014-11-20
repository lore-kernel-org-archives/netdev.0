From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: Query about Dynamic Right Sizing implementation in linux-kernel
Date: Thu, 20 Nov 2014 10:43:08 +0200
Message-ID: <CAEnQRZDdbTHEFaYjbDTth-7QthiExtdVRCiehMVR1xZGa+q66A@mail.gmail.com>
References: <1416410264.14060.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<1264093102.132748.1416470440737.JavaMail.root@mail.cse.iitm.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: cprasad@cse.iitm.ac.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:40409 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaKTInK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 03:43:10 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so11829898wib.1
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 00:43:09 -0800 (PST)
In-Reply-To: <1264093102.132748.1416470440737.JavaMail.root@mail.cse.iitm.ac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 10:00 AM,  <cprasad@cse.iitm.ac.in> wrote:
> Hi,
>
> Could you please tell how can i get access to the logs prior to Linux-2.6.12-rc2. I had already gone through the git logs. This was the last line in the logs.
>
> Linux-2.6.12-rc2
>
>     Initial git repository build. I'm not bothering with the full history,
>     even though we have it. We can create a separate "historical" git
>     archive of that later if we want to, and in the meantime it's about
>     3.2GB when imported into git - space that would just make the early
>     git days unnecessarily complicated, when we don't have a lot of good
>     infrastructure for it.
>
>     Let it rip!

Try this:

https://git.kernel.org/cgit/linux/kernel/git/tglx/history.git/

Daniel.
