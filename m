From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH nf-next v5 0/3] xtables socket classid matching
Date: Sat, 04 Jan 2014 15:48:50 +0100
Message-ID: <52C81F52.5080904@redhat.com>
References: <1388338032-14713-1-git-send-email-dborkman@redhat.com> <52C264F6.7050602@huawei.com> <20140103225613.GA18418@localhost> <52C7D76A.3020106@redhat.com> <20140104144642.GA4010@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140104144642.GA4010@localhost>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/04/2014 03:46 PM, Pablo Neira Ayuso wrote:
> On Sat, Jan 04, 2014 at 10:42:02AM +0100, Daniel Borkmann wrote:
>> On 01/03/2014 11:56 PM, Pablo Neira Ayuso wrote:
>>> On Tue, Dec 31, 2013 at 02:32:22PM +0800, Li Zefan wrote:
>>>> On 2013/12/30 1:27, Daniel Borkmann wrote:
>>>>> The main patch is patch 3, please refer to the detailled description
>>>>> there. Patch 1 has been requested by cgroups people to have as a
>>>>> cleanup. While at it, I've also added a minor, trivial cleanup in
>>>>> patch 2 for consistency reasons.
>>>>>
>>>>
>>>> Looks good to me.
>>>
>>> Series applied, thanks.
>>
>> Thanks a lot Pablo, as mentioned in [1], the _unchanged_ user space
>> part is available in [2].
>>
>> Let me know if you want me to resend it, or if you would like to
>> take it from there.
>
> No need to. I have applied that patch to iptables-next, thanks.

Awesome, thanks Pablo!
