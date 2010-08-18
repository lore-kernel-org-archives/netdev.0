From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Inconsistent lock state in ipt_do_table
Date: Wed, 18 Aug 2010 21:26:32 +0800
Message-ID: <AANLkTimWeZHQk3Z8MTa1ajhP1-CJV_nSwxNvEVuMfAoK@mail.gmail.com>
References: <4C6ACAB5.2090507@csr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Vrabel <david.vrabel@csr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44196 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab0HRN0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:26:53 -0400
Received: by wyb32 with SMTP id 32so782709wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 06:26:52 -0700 (PDT)
In-Reply-To: <4C6ACAB5.2090507@csr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 18, 2010 at 1:45 AM, David Vrabel <david.vrabel@csr.com> wrote:
> Is this related to or fixed by
>
> http://marc.info/?l=linux-netdev&m=128202731626693&w=2
>

I am afraid not. Please try this patch:
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=patch;h=001389b9581c13fe5fc357a0f89234f85af4215d



-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
