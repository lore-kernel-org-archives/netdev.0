From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 11571] New: u32_classify Kernel Panic
Date: Wed, 17 Sep 2008 21:38:32 +0200
Message-ID: <20080917193832.GA2623@ami.dom.local>
References: <20080916091508.a0cd830e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	m0sia@plotinka.ru
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:63789 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbYIQTic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 15:38:32 -0400
Received: by mu-out-0910.google.com with SMTP id g7so2473108muf.1
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2008 12:38:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080916091508.a0cd830e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 09/16/2008 06:15 PM:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Mon, 15 Sep 2008 03:35:16 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=11571
>>
>>            Summary: u32_classify Kernel Panic
...

Could you add more details:
- .config
- gzipped cls_u32.o (compiled with CONFIG_DEBUG_INFO on)
- the first part of OOPS if possible.
- more exactly these tc commands from your script

Does this happen while creating or deleting something and is this
easy to reproduce?

Thanks,
Jarek P.
