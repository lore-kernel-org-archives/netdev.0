From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 17 Dec 2007 21:27:38 -0500
Message-ID: <4767301A.5010108@garzik.org>
References: <20071218020142.GA1580@havoc.gtf.org> <47672D55.2000503@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53073 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642AbXLRC1k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 21:27:40 -0500
In-Reply-To: <47672D55.2000503@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> Jeff Garzik wrote:
>>
>> A couple serious fixes (wireless, e100, sky2) and a bevy of minor ones.
>>
>> Please pull from 'upstream-linus' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git 
>> upstream-linus
>>
> 
> Hi Jeff,
> 
> Should I resend the 2 cxgb3 patches posted on 12/05 and 12/06 ?
> I did not see them getting applied to the #upstream branch today.
> 
> Cheers,
> Divy
> 
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

The last thing I have from you, in netdev#upstream, is

commit 75758e8aa4b7d5c651261ce653dd8d0b716e1eda
Author: Divy Le Ray <divy@chelsio.com>
Date:   Wed Dec 5 10:15:01 2007 -0800

     cxgb3 - T3C support update

     Update GPIO mapping for T3C.
     Update xgmac for T3C support.
     Fix typo in mtu table.

and there's nothing in my inbox.

So if that is not the change you want, yes, please do resend.

	Jeff


