From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [iproute PATCH v3 3/5] ipaddress: fix ipaddr_flush for Linux >=
 3.1
Date: Wed, 25 Nov 2015 17:40:13 +0300
Message-ID: <5655C84D.1060605@cogentembedded.com>
References: <20151123163115.5f8be482@xeon-e3>
 <1448375464-12145-1-git-send-email-phil@nwl.cc>
 <1448375464-12145-4-git-send-email-phil@nwl.cc>
 <5655B944.8030903@cogentembedded.com> <20151125143208.GD23115@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35941 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbbKYOkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 09:40:16 -0500
Received: by lfs39 with SMTP id 39so60761315lfs.3
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 06:40:14 -0800 (PST)
In-Reply-To: <20151125143208.GD23115@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/25/2015 5:32 PM, Phil Sutter wrote:

>> On 11/24/2015 5:31 PM, Phil Sutter wrote:
>>
>>> Linux version 3.1 introduced a consistency check for netlink dumps in
>>> commit 670dc28 ("netlink: advertise incomplete dumps"). This bites
>>
>>      Need 12-digit SHA1 here, scripts/checkpatch.pl checks this now.

> Dejavu! [1]

    Oh, indeed! Sorry about that, don't remember already. :-)

> Again, this is luckily just iproute2. But thanks again for the reminder,

     Yeah, I didn't look at the subject too closely... :-/

> I've set 'core.abbrev = 13' now globally on all my machines, that should
> hold for a while. :)

> Cheers, Phil
>
> [1]: https://www.mail-archive.com/netdev@vger.kernel.org/msg86385.html

MBR, Sergei
