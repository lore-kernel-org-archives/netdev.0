From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take5 3/7] add interface for netconsole using
 sysfs
Date: Tue, 19 Jun 2007 19:03:25 +0900
Message-ID: <4677A9ED.80208@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC6BB.4040105@bx.jp.nec.com> <a781481a0706130849u2373983eyeab365a8bc90a4dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:50900 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950AbXFSKD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 06:03:57 -0400
In-Reply-To: <a781481a0706130849u2373983eyeab365a8bc90a4dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Satyam,

First, I'm sorry I couldn't reply to your comments.
I'm so appreciate for your comments.

I will fix my patches following your advices.
But, I have some questions on the another patches. So, I want to ask you
some questions and answer your questions.

>> +static int miscdev_configured;
> 
> Is this really required? We just return with error if misc_register()
> fails during module init time itself, so it's not really useful ever, is 
> it?

You're right. It isn't required.

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com






