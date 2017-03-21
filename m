From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH nf v2 1/1] netfilter: snmp: Fix one possible panic when
 snmp_trap_helper fail to register
Date: Tue, 21 Mar 2017 08:26:04 +0800
Message-ID: <CA+6hz4r+VQmL+-2dhLO0jjnydrR9FgM_9f-+XtUQid7OUJz1_Q@mail.gmail.com>
References: <1490003728-33866-1-git-send-email-fgao@ikuai8.com>
 <02f61fe0-37d9-8837-1c8f-390c5dea6ff4@cogentembedded.com> <CA+6hz4pkQR0xvwru2cr8gPgsC6aeEXh+45+82awk_BE5D-mqTQ@mail.gmail.com>
 <4da3e4cf-bcfa-e0fe-539c-4fc03e8959a9@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>, jolsa@redhat.com,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4da3e4cf-bcfa-e0fe-539c-4fc03e8959a9@cogentembedded.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 21, 2017 at 12:35 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 03/20/2017 01:15 PM, Feng Gao wrote:
>
>>>> From: Gao Feng <fgao@ikuai8.com>
>>>>
>>>> In the commit <93557f53e1fb> ("netfilter: nf_conntrack: nf_conntrack
>>>> snmp
>>>
>>>
>>>
>>>    Angle brackets not needed. :-)
>>>    The commit citing style is the same as for the Fixes: tag.
>>
>>
>> The checkpatch.pl reports the following error, if remove the angle
>> brackets.
>
>
>    Because it stops recognizing the commit ID! :-)
>
>> ERROR: Please use git commit description style 'commit <12+ chars of
>> sha1> ("<title line>")' - ie: 'commit fatal: ambig ("evision or path
>> not in the working tree.")'
>
>
>    So check the patch in the correct tree because that seems to be the
> problem... Angle brackets are surely not required.

Actually I didn't add the angle brackets firstly, but it fail to pass
the check_patch.pl check.
So I had to modify it.

Ok, I removed the angle brackets now, just ignored the error report of
check_patch.pl.

Best Regards
Feng

>
>> #7:
>> In the commit 93557f53e1fb ("netfilter: nf_conntrack: nf_conntrack snmp
>>
>> total: 1 errors, 0 warnings, 0 checks, 27 lines checked
>>
>>
>> Regards
>> Feng
>
>
> [...]
>
> MBR, Sergei
>
