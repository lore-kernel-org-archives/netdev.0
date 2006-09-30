From: "Wong Edison" <hswong3i@gmail.com>
Subject: Re: [PATCH] tcp-lp: prevent chance for oops
Date: Sat, 30 Sep 2006 18:54:46 +0800
Message-ID: <3feffd230609300354w5d00128bs105c1647869b69c3@mail.gmail.com>
References: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
	 <20060928.144029.32722435.davem@davemloft.net>
	 <3feffd230609291226n673d9aa4s2f16fbacd34cfc48@mail.gmail.com>
	 <20060929.141940.39158284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:20721 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1750777AbWI3Kyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Sep 2006 06:54:46 -0400
Received: by py-out-1112.google.com with SMTP id n25so1646419pyg
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2006 03:54:46 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060929.141940.39158284.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

oic i learn it and will change it in coming on version

On 9/30/06, David Miller <davem@davemloft.net> wrote:
> From: "Wong Edison" <hswong3i@gmail.com>
> Date: Sat, 30 Sep 2006 03:27:00 +0800
>
> > I do this since i have a sourceforge homepage for it. I update the
> > CVS version there, test, and then submit to netdev. As I sync code
> > in both side, this $Id$ is keeped.  May you just let it be? I think
> > it will let my maintenance become more simple...
>
> You could not even generate a clean patch to me, it just
> gets in the way and causes more work for me and anyone
> else who tries to use your patches.
>
> If you want to use versioning, use MODULE_VERSION() just like
> everyone else in the kernel does.
>
