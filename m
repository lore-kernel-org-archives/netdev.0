From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip link: Shortify printing the usage of link type
Date: Tue, 30 Sep 2014 08:27:28 +0300
Message-ID: <CAMw6YJKK35cGGcYwny2cMV2bf632ueeee5Vi8ikUf8-aGxaFMQ@mail.gmail.com>
References: <1411166627-23848-1-git-send-email-vadim4j@gmail.com>
	<20140929085038.7d2b5de3@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:47450 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaI3F1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 01:27:30 -0400
Received: by mail-we0-f179.google.com with SMTP id u56so6325799wes.38
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 22:27:28 -0700 (PDT)
In-Reply-To: <20140929085038.7d2b5de3@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed conflicts in the v2.

On Mon, Sep 29, 2014 at 6:50 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Sat, 20 Sep 2014 01:43:47 +0300
> Vadim Kochan <vadim4j@gmail.com> wrote:
>
>> Allow to print particular link type usage by:
>>
>>     ip link help [TYPE]
>>
>> Currently to print usage for some link type it is needed
>> to use the following way:
>>
>>     ip link { add | del | set } type TYPE help
>>
>> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>
> I like this, but does not apply to current iproute2 tree.
> Probably because I took in some other patches.
