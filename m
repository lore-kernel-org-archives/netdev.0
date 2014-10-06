From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 1/1] RFC: obsolete direct invocation of police
Date: Mon, 6 Oct 2014 10:01:32 -0700
Message-ID: <20141006100132.032e75bc@urahara>
References: <1412595960-7862-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:37777 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014AbaJFRBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:01:45 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so3606934pdb.3
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 10:01:45 -0700 (PDT)
In-Reply-To: <1412595960-7862-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  6 Oct 2014 07:46:00 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> I realize this may be controversial. I dont think people are still using
> the 1990s syntax anymore. This is one way to test it.
> We want to eventually phase out the kernel hacks for backward compat.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

I think iproute utilities needs to accept the old syntax and warn about
deprecated syntax use. Later (like 2yr +) the code can be removed.

The old syntax can be removed from all documentation and help messages
now though.
