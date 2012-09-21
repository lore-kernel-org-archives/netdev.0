From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH 0/6] xfrm_user info leaks
Date: Fri, 21 Sep 2012 07:37:29 +0200
Message-ID: <CA+rthh8iRhymobiYMi=9TrO1FGfrHBrPZzCpsUgnKXsjD0bZiA@mail.gmail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
	<20120920.180949.2287169159603922703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45984 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab2IUFha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 01:37:30 -0400
In-Reply-To: <20120920.180949.2287169159603922703.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 21, 2012 at 12:09 AM, David Miller <davem@davemloft.net> wrote:
> From: Mathias Krause <minipli@googlemail.com>
> Date: Wed, 19 Sep 2012 23:33:37 +0200
>
>> the following series fixes various info leaks in the xfrm netlink
>> interface. As always, a test case can be supplied on request.
>>
>> Patches 1 to 5 are probably material for stable, too. Patch 6 is just a
>> minor optimization I stumbled across while auditing the code.
>>
>> Please apply!
>
> All applied, and I made sure to use v3 of patch #5 (which you marked
> as 5/7 instead of 5/6 :-)

Sorry for the confusion. Looks like I've to learn a few more git
tricks, so this won't happen again ;)

> Also, these have been queued up for -stable as well.

Thanks!
