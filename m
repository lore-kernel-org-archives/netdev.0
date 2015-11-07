From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] man: Syntax and warning fixes
Date: Sat, 7 Nov 2015 09:40:47 -0700
Message-ID: <563E298F.4070200@cumulusnetworks.com>
References: <1446889471-22296-1-git-send-email-ville.skytta@iki.fi>
 <CAMu38xJwGcNgXKEZbuNFkEYDCtUoE1=xh6o3VziVOzwxdogkgg@mail.gmail.com>
 <CABr9L5B67DkOv8hY7eqogUxrcX+MaaYT3KKtM1W_V5eYpzPpXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Ville_Skytt=c3=a4?= <ville.skytta@iki.fi>,
	Albino B Neto <bino@bino.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34092 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbbKGQkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 11:40:49 -0500
Received: by iody8 with SMTP id y8so150447606iod.1
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 08:40:48 -0800 (PST)
In-Reply-To: <CABr9L5B67DkOv8hY7eqogUxrcX+MaaYT3KKtM1W_V5eYpzPpXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/15 2:55 AM, Ville Skytt=C3=A4 wrote:
> On Sat, Nov 7, 2015 at 11:47 AM, Albino B Neto <bino@bino.us> wrote:
>> 2015-11-07 7:44 GMT-02:00 Ville Skytt=C3=A4 <ville.skytta@iki.fi>:
>>> ---
>>>   man/man8/tc-bpf.8         | 2 +-
>>>   man/man8/tipc-bearer.8    | 4 ++--
>>>   man/man8/tipc-link.8      | 6 +++---
>>>   man/man8/tipc-media.8     | 4 ++--
>>>   man/man8/tipc-nametable.8 | 4 ++--
>>>   man/man8/tipc-node.8      | 4 ++--
>>>   man/man8/tipc-socket.8    | 4 ++--
>>>   7 files changed, 14 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
>>> index 2c02ab2..f5201d3 100644
>>> --- a/man/man8/tc-bpf.8
>>> +++ b/man/man8/tc-bpf.8
>>> @@ -844,7 +844,7 @@ result in the default classid:
>>>   Basically, such a minimal generator is equivalent to:
>>
>> Signed-off-by and description ?
>
> Superseding patches sent separately. I suggest documenting the
> requirement for Signed-off-by somewhere (README.devel?); git log show=
s
> lots of commits without it, especially a bunch of man page related
> ones about a week ago.

I believe man page changes should cc linux-man@vger.kernel.org
