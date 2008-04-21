From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: New GIT net tree naming...
Date: Mon, 21 Apr 2008 10:53:16 +0300
Message-ID: <d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com>
References: <20080419.173510.257216556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:46690 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbYDUHxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 03:53:18 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1673457fgb.17
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 00:53:17 -0700 (PDT)
In-Reply-To: <20080419.173510.257216556.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
Sorry for my ignorance, but what is the password that I need to enter
when prompted to ?

when running:
git-clone master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master
Initialized empty Git repository in /work/src/master/.git/
I get:
root@master.kernel.org's password:

The same is for the
master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
tree.

Regards,
Ian



On Sun, Apr 20, 2008 at 3:35 AM, David Miller <davem@davemloft.net> wrote:
>
>  Based upon feedback from Andrew and others I'm now starting
>  to use a new naming scheme for my GIT trees:
>
>  For changes against Linus's current tree:
>
>    master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
>
>  For development meant to be merged in the next merge
>  window we have:
>
>    master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>
>  Andrew/Stephen, let me know if this works for you.  This way
>  the tree names will never change.
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
