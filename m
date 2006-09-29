From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp-lp: prevent chance for oops
Date: Fri, 29 Sep 2006 14:19:40 -0700 (PDT)
Message-ID: <20060929.141940.39158284.davem@davemloft.net>
References: <3feffd230609280343o1975ee70o8a55acf3e5d4769e@mail.gmail.com>
	<20060928.144029.32722435.davem@davemloft.net>
	<3feffd230609291226n673d9aa4s2f16fbacd34cfc48@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14501
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964834AbWI2VTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:19:39 -0400
To: hswong3i@gmail.com
In-Reply-To: <3feffd230609291226n673d9aa4s2f16fbacd34cfc48@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wong Edison" <hswong3i@gmail.com>
Date: Sat, 30 Sep 2006 03:27:00 +0800

> I do this since i have a sourceforge homepage for it. I update the
> CVS version there, test, and then submit to netdev. As I sync code
> in both side, this $Id$ is keeped.  May you just let it be? I think
> it will let my maintenance become more simple...

You could not even generate a clean patch to me, it just
gets in the way and causes more work for me and anyone
else who tries to use your patches.

If you want to use versioning, use MODULE_VERSION() just like
everyone else in the kernel does.
