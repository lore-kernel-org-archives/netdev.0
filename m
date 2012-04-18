From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: RE: [PATCH 00/14] usb/net: rndis: first step toward consolidation
Date: Wed, 18 Apr 2012 21:14:51 +0300
Message-ID: <20120418211451.20071p46rovwu5q8@www.81.fi>
References: <1333874813-3861-1-git-send-email-linus.walleij@linaro.org>
 <A1F3067C9B68744AA19F6802BAB8FFDC0DD215D0@TK5EX14MBXC222.redmond.corp.microsoft.com>
 <CACRpkdZ79RtQDeQnFczsH8noX01Qp5cmAPysVs-5v=Nb=aBw=Q@mail.gmail.com>
 <A1F3067C9B68744AA19F6802BAB8FFDC0DD33174@TK5EX14MBXC221.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Linus Walleij <linus.walleij@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:50945 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279Ab2DRSO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 14:14:57 -0400
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DD33174@TK5EX14MBXC221.redmond.corp.microsoft.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Haiyang Zhang <haiyangz@microsoft.com>:

>> -----Original Message-----
>> From: Linus Walleij [mailto:linus.walleij@linaro.org]
>> Sent: Wednesday, April 18, 2012 8:26 AM
>> To: Haiyang Zhang
>> Cc: netdev@vger.kernel.org; linux-usb@vger.kernel.org; Greg Kroah-
>> Hartman; David S. Miller; Felipe Balbi; Jussi Kivilinna; Wei Yongjun; Ben
>> Hutchings
>> Subject: Re: [PATCH 00/14] usb/net: rndis: first step toward consolidation
>>
>> On Sun, Apr 8, 2012 at 3:58 PM, Haiyang Zhang <haiyangz@microsoft.com>
>> wrote:
>> > _______________________________________
>> >> From: Linus Walleij [linus.walleij@linaro.org]
>> >> Sent: Sunday, April 08, 2012 4:46 AM
>> >> To: netdev@vger.kernel.org; linux-usb@vger.kernel.org; Greg
>> >> Kroah-Hartman; David S. Miller; Felipe Balbi
>> >> Cc: Jussi Kivilinna; Haiyang Zhang; Wei Yongjun; Ben Hutchings; Linus
>> >> Walleij
>> >> Subject: [PATCH 00/14] usb/net: rndis: first step toward
>> >> consolidation
>> >
>> >> So if you like this, let's proceed, but if you're all in "I wanna
>> >> keep this one implementation in my corner" I'll just give up right now.
>> >
>> >> So: what do you think?
>> >
>> > I will test this soon.
>>
>> Ping on this... any testing so far?
>
> I saw Jussi Kivilinna <jussi.kivilinna@mbnet.fi>'s comments saying  
> it does not
> work. And your patches are in "changes requested" state. So I'm waiting for
> your updated patches before testing.
>

Maybe I should clarify that at least rndis_wlan does not work because  
of that single patch (09/14). By fixing the problem, the patch-set  
works with rndis_wlan fine.

-Jussi

> Thanks,
> - Haiyang
>
>
>
>
