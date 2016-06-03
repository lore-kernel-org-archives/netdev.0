From: Dan Streetman <dan.streetman@canonical.com>
Subject: Re: [PATCH stable] Set a large MTU on ovs-created tunnel devices
Date: Fri, 3 Jun 2016 16:10:12 -0400
Message-ID: <CAOZ2QJMO1xEpzS4RVb=ovpMjpDXN-bSjUYpbTvGVAULwsfOnPA@mail.gmail.com>
References: <CAOZ2QJNufB+4ffEpaab6iWotM_4+PQKVcEorEN9Hckh3NiJaQA@mail.gmail.com>
 <20160603.114418.907250018461386490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:34616 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538AbcFCUKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 16:10:53 -0400
Received: by mail-yw0-f179.google.com with SMTP id c127so90624615ywb.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 13:10:52 -0700 (PDT)
In-Reply-To: <20160603.114418.907250018461386490.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 3, 2016 at 2:44 PM, David Miller <davem@davemloft.net> wrote:
> From: Dan Streetman <dan.streetman@canonical.com>
> Date: Fri, 3 Jun 2016 13:49:09 -0400
>
>> Can you queue up these commits for stable?
>
> This stuff doesn't cleanly backport, I tried several times already.

ah sorry.  i'll get a backport.

>
> Therfore, someone knowledgable with OVS is going to have to do the
> backport, test it, and post it for me to submit.
>
> Thanks.
