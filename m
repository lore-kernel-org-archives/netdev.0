From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poorer networking performance in later kernels?
Date: Mon, 18 Apr 2016 11:05:05 -0700
Message-ID: <1461002705.10638.121.camel@edumazet-glaptop3.roam.corp.google.com>
References: <SN1PR0301MB19987565B71A4688593A2CDBD6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
	 <SN1PR0301MB19983946D7A38001E4B54D20D6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
	 <1460759582.10638.79.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1460981814.10638.104.camel@edumazet-glaptop3.roam.corp.google.com>
	 <BY2PR0301MB1990B79988EF1A3FB461882FD66B0@BY2PR0301MB1990.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Butler, Peter" <pbutler@sonusnet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34464 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbcDRSFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 14:05:08 -0400
Received: by mail-pf0-f173.google.com with SMTP id c20so83111265pfc.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 11:05:07 -0700 (PDT)
In-Reply-To: <BY2PR0301MB1990B79988EF1A3FB461882FD66B0@BY2PR0301MB1990.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 16:27 +0000, Butler, Peter wrote:
> Hi Eric
> 
> Thanks for your response.  My apologies for being late in getting back
> to you - I wasn't able to have access to the lab hardware on the
> weekend.
> 
> I performed your test as suggested - I've provided a side-by-side diff
> of the nstat output below for the SCTP test only (not the TCP test).
> Note that the fields that are output are somewhat different for the
> two kernels - i.e. some fields exist in one but not the other
> (presumably this comes from the kernel internals?).
> 
> Other than seeing 'larger' throughput numbers in this output I'm not
> sure what to take from it - I'm certainly not a networking
> expert :-(   Let me know if there's anything that speaks to you.
> 
> Note that this test was again done on a clean, freshly rebooted and
> idle system.  Let me know if there's any issues with the output format
> of this data in the email.
> 
> Thanks,
> 
> Peter


OK, please do not top-post on netdev.


I can not really comment on SCTP, could you please post numbers with
TCP ?

Thanks !
