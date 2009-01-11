From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: can't apply sch_multiq
Date: Sun, 11 Jan 2009 09:06:20 +0300
Message-ID: <49698C5C.6040609@bigtelecom.ru>
References: <4963392A.2000709@bigtelecom.ru> <80769D7B14936844A23C0C43D9FBCF0F24A2DE19@orsmsx501.amr.corp.intel.com> <Pine.LNX.4.64.0901071304130.11851@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:57404 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbZAKGGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 01:06:24 -0500
In-Reply-To: <Pine.LNX.4.64.0901071304130.11851@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks all!

I hope iproute2 build release for new features what added at 2.6.28 =)

Best regals, Badalian Vyacheslav

>
> On Tue, 6 Jan 2009, Duyck, Alexander H wrote:
>
>> Badalian Vyacheslav wrote:
>>> Hello all.
>>> kernel 2.6.28, iproute2 - 2.6.26 (last release)
>>>
>> The only part that is probably missing is that I don't believe the
>> sch_multiq patch been accepted into the iproute2.  Once that is in
>> then tc should work with the multiq qdisc without any issues.
>
> You can use the lastest iproute2 git tree at:
>
>  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
>
> I just checked that the sch_multiq changes have been added to this
> tree (although it looks like Stephen just added that patch yesterday ;-))
>
> Cheers,
>   Jesper Brouer
>
> -- 
> -------------------------------------------------------------------
> MSc. Master of Computer Science
> Dept. of Computer Science, University of Copenhagen
> Author of http://www.adsl-optimizer.dk
> -------------------------------------------------------------------
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

