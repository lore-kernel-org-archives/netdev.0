From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [ SPAM ] Re: DCA/IOAT problem
Date: Mon, 26 Jan 2009 22:01:51 +0100
Message-ID: <497E24BF.6060006@itcare.pl>
References: <497DF609.9000600@chelsio.com> <497E13B8.9040803@itcare.pl> <497E1BE1.4020301@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:52192 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538AbZAZVBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 16:01:54 -0500
In-Reply-To: <497E1BE1.4020301@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin pisze:
> Pawe=C5=82 Staszewski wrote:
>  =20
>> ioatdma 0000:00:08.0: DCA is disabled in BIOS
>>
>> Why DCA is not working (or workink but no info about in ioat)
>>    =20
>
> See above in dmesg: It's disabled in BIOS. If the BIOS doesn't have a=
n
> option to enable DCA, you need to talk to your vendor. Or you can try
> changing registers on the chipset manually...
>
> Brice
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>  =20
yes ok.
but in bios i have an option to enable DCA and i make it. (so DCA is=20
enabled in bios )

thats why i ask question why is not enabled :)

So i think only changing registers may help ...

Thanks for reply.

