From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 1/1] RFC: obsolete direct invocation of police
Date: Tue, 07 Oct 2014 07:32:09 -0400
Message-ID: <5433CF39.5030202@mojatatu.com>
References: <1412595960-7862-1-git-send-email-jhs@emojatatu.com> <20141006100132.032e75bc@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:63747 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbaJGLcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 07:32:12 -0400
Received: by mail-ie0-f177.google.com with SMTP id rd18so5087088iec.22
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 04:32:11 -0700 (PDT)
In-Reply-To: <20141006100132.032e75bc@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/14 13:01, Stephen Hemminger wrote:

> I think iproute utilities needs to accept the old syntax and warn about
> deprecated syntax use. Later (like 2yr +) the code can be removed.
>
> The old syntax can be removed from all documentation and help messages
> now though.

Ok, so ignore that one patch. I will send another one.
Fair to put a date for when the obsoletion notice went out?
Example:
"As of October 10, 2014 this syntax is obsolete. Please use instead ..."
Maybe also mention when the approximate cutoff date is.

cheers,
jamal
