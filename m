From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: New GIT net tree naming...
Date: Mon, 21 Apr 2008 11:13:47 +0300
Message-ID: <d0383f90804210113l5a9b41adra9a0125869917f3a@mail.gmail.com>
References: <20080419.173510.257216556.davem@davemloft.net>
	 <d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com>
	 <20080421.170026.131839483.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:22876 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323AbYDUINv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 04:13:51 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1678555fgb.17
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 01:13:47 -0700 (PDT)
In-Reply-To: <20080421.170026.131839483.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks.

>  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
>  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

OK , these URL worked for me.

last question:

Do I understand correctly - patches sent for this mailing list from
now on are for davem/net-2.6.git tree and not for the
davem/net-next-2.6.git ? or they can be for both, and we can
understand from the patch title to which git tree they are ?
IB


On Mon, Apr 21, 2008 at 11:00 AM, YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org> wrote:
> In article <d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com> (at Mon, 21 Apr 2008 10:53:16 +0300), "Ian Brown" <ianbrn@gmail.com> says:
>
>  > when running:
>  > git-clone master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master
>  > Initialized empty Git repository in /work/src/master/.git/
>  > I get:
>  > root@master.kernel.org's password:
>  >
>  > The same is for the
>  > master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>  > tree.
>
>  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
>  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>
>  I'd not recommend to run git as root, BTW.
>
>  --yoshfuji
>
