From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 1/1] RFC: obsolete direct invocation of police
Date: Tue, 7 Oct 2014 09:04:25 -0700
Message-ID: <20141007090425.007bbd37@urahara>
References: <1412595960-7862-1-git-send-email-jhs@emojatatu.com>
	<20141006100132.032e75bc@urahara>
	<5433CF39.5030202@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34308 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363AbaJGQEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:04:37 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so7453449pad.11
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 09:04:37 -0700 (PDT)
In-Reply-To: <5433CF39.5030202@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2014 07:32:09 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 10/06/14 13:01, Stephen Hemminger wrote:
> 
> > I think iproute utilities needs to accept the old syntax and warn about
> > deprecated syntax use. Later (like 2yr +) the code can be removed.
> >
> > The old syntax can be removed from all documentation and help messages
> > now though.
> 
> Ok, so ignore that one patch. I will send another one.
> Fair to put a date for when the obsoletion notice went out?
> Example:
> "As of October 10, 2014 this syntax is obsolete. Please use instead ..."
> Maybe also mention when the approximate cutoff date is.

Don't put a date in, it either will look silly, or will be ignored.
Make message a short direct one liner.
