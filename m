From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: Re: [PATCH resend] README: clarify redistribution requirements
 covering patents
Date: Tue, 19 May 2015 13:18:14 -0700
Message-ID: <CAB=NE6WxMid+eNOoHZ__kbvP3BktHuYip+fQwVDydJQbQ1No_g@mail.gmail.com>
References: <1431626160-10885-1-git-send-email-mcgrof@do-not-panic.com> <5554E99A.5030302@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kyle McMartin <kyle-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-firmware-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	One Thousand Gnomes <gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5554E99A.5030302-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, May 14, 2015 at 11:29 AM, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
> On 05/14/15 19:56, Luis R. Rodriguez wrote:
>> diff --git a/README b/README
>> index f2ed92e..d2a56ec 100644
>> --- a/README
>> +++ b/README
>> @@ -18,7 +18,10 @@ and also cc: to related mailing lists.
>>
>>   Your commit should include an update to the WHENCE file clearly
>>   identifying the licence under which the firmware is available, and
>> -that it is redistributable. If the licence is long and involved, it's
>> +that it is redistributable. Being redistributable includes ensuring
>> +the firmware license provided includes an implicit or explicit
>> +patent grant to end users to ensure full functionality of device
>> +operation with the firmware. If the licence is long and involved, it's
>
>
> Just nitpicking here, but there is 'license' and 'licence' being used here.
> Better stick to one and preferably 'license'.

Fixed, will submit a v2.

 Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
