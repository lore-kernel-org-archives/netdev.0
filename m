From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH] iproute2 tests: Fix problem with test running
Date: Fri, 5 Sep 2014 20:09:05 +0300
Message-ID: <CAMw6YJK-dN1c-LQejXbH59PM4Z1n5uj4EZPiuBwekpb3sOYMvw@mail.gmail.com>
References: <1409935591-30145-1-git-send-email-vadim4j@gmail.com>
	<20140905100707.16c063e2@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:61368 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIERJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 13:09:06 -0400
Received: by mail-qc0-f173.google.com with SMTP id w7so12477112qcr.18
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 10:09:05 -0700 (PDT)
In-Reply-To: <20140905100707.16c063e2@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eff, mistake ...

On Fri, Sep 5, 2014 at 8:07 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri,  5 Sep 2014 19:46:31 +0300
> Vadim Kochan <vadim4j@gmail.com> wrote:
>
>> index 2a4e0ba..6f2ea85 100644
>> --- a/testsuite/Makefile
>> +++ b/testsuite/Makefile
>> @@ -1,6 +1,7 @@
>>  ## -- Config --
>>  DEV := lo
>>  PREFIX := sudo
>> +RESULTS_DIR := "results"
>
> Why the quotes?
