From: =?UTF-8?Q?Ville_Skytt=C3=A4?= <ville.skytta@iki.fi>
Subject: Re: [PATCH] man: Syntax and warning fixes
Date: Sat, 7 Nov 2015 11:55:19 +0200
Message-ID: <CABr9L5B67DkOv8hY7eqogUxrcX+MaaYT3KKtM1W_V5eYpzPpXQ@mail.gmail.com>
References: <1446889471-22296-1-git-send-email-ville.skytta@iki.fi> <CAMu38xJwGcNgXKEZbuNFkEYDCtUoE1=xh6o3VziVOzwxdogkgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Albino B Neto <bino@bino.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:35174 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbbKGJzk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 04:55:40 -0500
Received: by lfbn126 with SMTP id n126so81842538lfb.2
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 01:55:39 -0800 (PST)
In-Reply-To: <CAMu38xJwGcNgXKEZbuNFkEYDCtUoE1=xh6o3VziVOzwxdogkgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 7, 2015 at 11:47 AM, Albino B Neto <bino@bino.us> wrote:
> 2015-11-07 7:44 GMT-02:00 Ville Skytt=C3=A4 <ville.skytta@iki.fi>:
>> ---
>>  man/man8/tc-bpf.8         | 2 +-
>>  man/man8/tipc-bearer.8    | 4 ++--
>>  man/man8/tipc-link.8      | 6 +++---
>>  man/man8/tipc-media.8     | 4 ++--
>>  man/man8/tipc-nametable.8 | 4 ++--
>>  man/man8/tipc-node.8      | 4 ++--
>>  man/man8/tipc-socket.8    | 4 ++--
>>  7 files changed, 14 insertions(+), 14 deletions(-)
>>
>> diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
>> index 2c02ab2..f5201d3 100644
>> --- a/man/man8/tc-bpf.8
>> +++ b/man/man8/tc-bpf.8
>> @@ -844,7 +844,7 @@ result in the default classid:
>>  Basically, such a minimal generator is equivalent to:
>
> Signed-off-by and description ?

Superseding patches sent separately. I suggest documenting the
requirement for Signed-off-by somewhere (README.devel?); git log shows
lots of commits without it, especially a bunch of man page related
ones about a week ago.
