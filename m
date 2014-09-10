From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: iwlwifi no authentication with AP - Re: pull request: wireless-next
 2014-09-08
Date: Wed, 10 Sep 2014 18:31:18 +0200
Message-ID: <54107CD6.5040109@hartkopp.net>
References: <20140908191630.GB29412@tuxdriver.com>	<540F5927.7000306@hartkopp.net>	<CANUX_P3n0v1SzfbYuaAsE4TY7Hz_wo2Fb9SmHVNyFOC9hDhwdg@mail.gmail.com>	<540F61D0.9000704@hartkopp.net>	<CAMw6YJLeO1JZeY6hNe-TXOS56b-otk+htt5VPPor+9iYCQz53Q@mail.gmail.com>	<540FDB3C.6060301@hartkopp.net>	<CANUX_P3kOetqEneHgqoCDN4c85SQYD-G=mQj_o1c_TvKmE5psA@mail.gmail.com> <CAMw6YJKgVVnDrn1X7atemC1r9kwvsr3PQDs4qx5KDeeNy-P3VA@mail.gmail.com> <54101888.8080601@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>,
	Emmanuel Grumbach <egrumbach@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:10349 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbaIJQbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 12:31:31 -0400
In-Reply-To: <54101888.8080601@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.09.2014 11:23, Oliver Hartkopp wrote:
> Hi all,
> 
> yes for me too.
> 
> Although I only could test it here with my mobile hotspot which only supports
> WEP ... but before that hotspot was not working too.
> 
> I'll check with my WPA2 setup again when I'm back home (if it's still needed).
> 

Just fyi - it also works @home with WPA2.
Tnx, Oliver

> So far feel free to add my
> 
> Reported-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> Many thanks for your quick reaction!
> 
> Best regards,
> Oliver
> 
> On 10.09.2014 11:16, Vadim Kochan wrote:
>> Hi,
>>
>> Your patch works for me.
>>
>> On Wed, Sep 10, 2014 at 11:24 AM, Emmanuel Grumbach <egrumbach@gmail.com> wrote:
>>> On Wed, Sep 10, 2014 at 8:01 AM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>>>> On 10.09.2014 00:07, Vadim Kochan wrote:
>>>>> I have the same issue with iwlwifi.
>>>>
>>>> I tried an old zd1211 wireless USB stick to check if this problem is 80211
>>>> related. But the USB stick works fine (I'm using it right now).
>>>> So its definitely looks like an iwlwifi issue.
>>>>
>>>>> iwlwifi 0000:02:00.0: fail to flush all tx fifo queues Q 0
>>>>
>>>> Wasn't there any change in the iwlwifi tx path recently??
>>>
>>> Can you please try the patch attached? It works for me.
>>>
>>>>
>>>> Regards,
>>>> Oliver
>>>>
>>>>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
