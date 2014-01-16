From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 16 Jan 2014 19:52:42 +0100
Message-ID: <52D82A7A.3090106@redhat.com>
References: <1389888898-31744-1-git-send-email-msekleta@redhat.com>  <52D80BCA.7030400@redhat.com> <20140116172631.GA5206@loki.brq.redhat.com>  <52D82626.5060701@redhat.com> <1389898146.31367.413.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbaAPSws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 13:52:48 -0500
In-Reply-To: <1389898146.31367.413.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2014 07:49 PM, Eric Dumazet wrote:
> On Thu, 2014-01-16 at 19:34 +0100, Daniel Borkmann wrote:
>
>>> Thank you for the review. Btw, what do you think about define for parisc? I am
>>
>> Yes, saw that in the patch and had similar thoughts.
>>
>>> not sure I grok 0x4048 for SO_MAX_PACING_RATE and hence not sure about 0x4029
>>> for SO_BPF_EXTENSIONS.
>>
>> Hmm, maybe typo; SO_MAX_PACING_RATE should have been a 0x4028 ?
>
> Indeed it was a typo.
>
> I think its time to change this, as this was added for linux-3.13

Ok, are you sending out a patch?

Thanks,

Daniel
