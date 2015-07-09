From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: net-next is OPEN
Date: Thu, 09 Jul 2015 20:48:36 +0300
Message-ID: <559EB3F4.3060000@cogentembedded.com>
References: <20150708.133041.2042093870138764891.davem@davemloft.net>	<559E5FCE.6010301@cogentembedded.com> <20150709.104019.370940061164391476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:35736 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbGIRsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 13:48:41 -0400
Received: by lblf12 with SMTP id f12so9886703lbl.2
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 10:48:39 -0700 (PDT)
In-Reply-To: <20150709.104019.370940061164391476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2015 08:40 PM, David Miller wrote:

>>> Please feel free to bombard me with net-next changes, which some of
>>> you have been doing already ;-(, as net-next is now open.

>>     Hm, I pulled and didn't see 4.2-rc1 tag. Is it normal?

> Why does it have to be there?

    I thought your pause during the merge window is caused by you wanting for 
-rc1 tagging in order for the possible conflicts to be resolved...

> I build net-next by pulling net into net-next.

    Well, that merge you do quite routinely. :-)

> Since 'net' is based upon Linus's tree before he added that tag
> there is no reason for it to have that tag at all.

> I really have no idea why you expect it to be there.

    I then don't quite understand why you close net-next during the merge 
window and beyond.

WBR, Sergei
