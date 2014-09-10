From: Vadim Kochan <vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlwifi no authentication with AP - Re: pull request:
 wireless-next 2014-09-08
Date: Wed, 10 Sep 2014 12:16:32 +0300
Message-ID: <CAMw6YJKgVVnDrn1X7atemC1r9kwvsr3PQDs4qx5KDeeNy-P3VA@mail.gmail.com>
References: <20140908191630.GB29412@tuxdriver.com>
	<540F5927.7000306@hartkopp.net>
	<CANUX_P3n0v1SzfbYuaAsE4TY7Hz_wo2Fb9SmHVNyFOC9hDhwdg@mail.gmail.com>
	<540F61D0.9000704@hartkopp.net>
	<CAMw6YJLeO1JZeY6hNe-TXOS56b-otk+htt5VPPor+9iYCQz53Q@mail.gmail.com>
	<540FDB3C.6060301@hartkopp.net>
	<CANUX_P3kOetqEneHgqoCDN4c85SQYD-G=mQj_o1c_TvKmE5psA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANUX_P3kOetqEneHgqoCDN4c85SQYD-G=mQj_o1c_TvKmE5psA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Your patch works for me.

On Wed, Sep 10, 2014 at 11:24 AM, Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Sep 10, 2014 at 8:01 AM, Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> wrote:
>> On 10.09.2014 00:07, Vadim Kochan wrote:
>>> I have the same issue with iwlwifi.
>>
>> I tried an old zd1211 wireless USB stick to check if this problem is 80211
>> related. But the USB stick works fine (I'm using it right now).
>> So its definitely looks like an iwlwifi issue.
>>
>>> iwlwifi 0000:02:00.0: fail to flush all tx fifo queues Q 0
>>
>> Wasn't there any change in the iwlwifi tx path recently??
>
> Can you please try the patch attached? It works for me.
>
>>
>> Regards,
>> Oliver
>>
>>>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
