From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 1/2] nbd: use list_for_each_entry_safe to make it more consolidated and readable
Date: Thu, 19 Jul 2007 23:55:18 +0800
Message-ID: <91b13c310707190855h6fee9604pcc86b6712d2c76f8@mail.gmail.com>
References: <11848376711601-git-send-email-crquan@gmail.com>
	 <469F7F58.4080709@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Pavel Machek" <pavel@ucw.cz>,
	"Steven Whitehouse" <steve@chygwyn.com>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Paul Clements" <paul.clements@steeleye.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:62867 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933090AbXGSPzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 11:55:20 -0400
Received: by ug-out-1314.google.com with SMTP id j3so436911ugf
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 08:55:19 -0700 (PDT)
In-Reply-To: <469F7F58.4080709@steeleye.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/19/07, Paul Clements <paul.clements@steeleye.com> wrote:
> Could you name "n" as "tmp" (as in the previous code) so that it's clear
> that's only a temporary variable. Other than that, this looks good.
Sure. I just use the name "n" as in the declaration of
list_for_each_entry_safe in the header file <linux/list.h>
I'll resend it a little later.

>
> Thanks,
> Paul
>

-- 
Denis Cheng
Linux Application Developer

"One of my most productive days was throwing away 1000 lines of code."
 - Ken Thompson.
