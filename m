From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 12:13:48 +0800
Message-ID: <CABa6K_E+EzeJQF_m4aoq1WAYUwWQxd8_=k7HT0XZ6P5EpBR+4g@mail.gmail.com>
References: <20120618.194016.2282814982594761206.davem@davemloft.net> <a22edf13-1bf5-49fb-8ebe-05054f68c129@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:53641 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab2FSEOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:14:09 -0400
Received: by qcro28 with SMTP id o28so3284822qcr.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:14:08 -0700 (PDT)
In-Reply-To: <a22edf13-1bf5-49fb-8ebe-05054f68c129@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 19, 2012 at 12:03 PM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
>
>>
>> You know you want it.
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> David, I understand it, Eric understands it, and maybe one or
> two others. But on the principal of what is "good for the goose
> is good for the gander", you really need to provide a reasonable
> change log entry. Just because you are the network maintainer
> doesn't mean you get to skip all the documented rules about submitting
> patches.

Agree. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
