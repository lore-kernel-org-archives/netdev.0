From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH net-next] net: Separate the close_list and the unreg_list
Date: Wed, 9 Oct 2013 17:22:59 -0700
Message-ID: <CA+HUmGgPoDsWxs+j87FbC2M=svL7H+zafmZgpz4yZfV5vTbhWg@mail.gmail.com>
References: <CA+HUmGg2LCX0zZAXgNhWwafBgi1HuePTLmxDu5VTUm7tX4TYMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:59262 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755273Ab3JJAXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 20:23:00 -0400
Received: by mail-oa0-f48.google.com with SMTP id m6so904115oag.7
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 17:22:59 -0700 (PDT)
In-Reply-To: <CA+HUmGg2LCX0zZAXgNhWwafBgi1HuePTLmxDu5VTUm7tX4TYMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 6, 2013 at 10:13 AM, Francesco Ruggeri
<fruggeri@aristanetworks.com> wrote:
>>
>> Can you verify this incremental change fixes it for you?
>>
>
> Sure, I will.
> Thanks,
>
> Francesco

Hi Eric,
I have been running this patch for a few days and I have not had any problems.
Thanks,
Francesco
