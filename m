From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] man: Syntax and warning fixes
Date: Mon, 09 Nov 2015 09:51:53 +0100
Message-ID: <56405EA9.1030800@iogearbox.net>
References: <1446889471-22296-1-git-send-email-ville.skytta@iki.fi> <CAMu38xJwGcNgXKEZbuNFkEYDCtUoE1=xh6o3VziVOzwxdogkgg@mail.gmail.com> <CABr9L5B67DkOv8hY7eqogUxrcX+MaaYT3KKtM1W_V5eYpzPpXQ@mail.gmail.com> <563E298F.4070200@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
	=?UTF-8?B?VmlsbGUgU2t5dHTDpA==?= <ville.skytta@iki.fi>,
	Albino B Neto <bino@bino.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46957 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbbKIIv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 03:51:59 -0500
In-Reply-To: <563E298F.4070200@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2015 05:40 PM, David Ahern wrote:
> On 11/7/15 2:55 AM, Ville Skytt=C3=A4 wrote:
>> On Sat, Nov 7, 2015 at 11:47 AM, Albino B Neto <bino@bino.us> wrote:
>>> 2015-11-07 7:44 GMT-02:00 Ville Skytt=C3=A4 <ville.skytta@iki.fi>:
>>>> ---
>>>>   man/man8/tc-bpf.8         | 2 +-
>>>>   man/man8/tipc-bearer.8    | 4 ++--
>>>>   man/man8/tipc-link.8      | 6 +++---
>>>>   man/man8/tipc-media.8     | 4 ++--
>>>>   man/man8/tipc-nametable.8 | 4 ++--
>>>>   man/man8/tipc-node.8      | 4 ++--
>>>>   man/man8/tipc-socket.8    | 4 ++--
>>>>   7 files changed, 14 insertions(+), 14 deletions(-)
>>>>
>>>> diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
>>>> index 2c02ab2..f5201d3 100644
>>>> --- a/man/man8/tc-bpf.8
>>>> +++ b/man/man8/tc-bpf.8
>>>> @@ -844,7 +844,7 @@ result in the default classid:
>>>>   Basically, such a minimal generator is equivalent to:
>>>
>>> Signed-off-by and description ?
>>
>> Superseding patches sent separately. I suggest documenting the
>> requirement for Signed-off-by somewhere (README.devel?); git log sho=
ws
>> lots of commits without it, especially a bunch of man page related
>> ones about a week ago.
>
> I believe man page changes should cc linux-man@vger.kernel.org

Not really needed, this is for iproute2, not man-pages project.
