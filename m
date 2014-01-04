From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH nf-next v5 0/3] xtables socket classid matching
Date: Sat, 04 Jan 2014 10:42:02 +0100
Message-ID: <52C7D76A.3020106@redhat.com>
References: <1388338032-14713-1-git-send-email-dborkman@redhat.com> <52C264F6.7050602@huawei.com> <20140103225613.GA18418@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Zefan <lizefan@huawei.com>, netfilter-devel@vger.kernel.org,
	cgroups@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbaADJmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 04:42:11 -0500
In-Reply-To: <20140103225613.GA18418@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/03/2014 11:56 PM, Pablo Neira Ayuso wrote:
> On Tue, Dec 31, 2013 at 02:32:22PM +0800, Li Zefan wrote:
>> On 2013/12/30 1:27, Daniel Borkmann wrote:
>>> The main patch is patch 3, please refer to the detailled description
>>> there. Patch 1 has been requested by cgroups people to have as a
>>> cleanup. While at it, I've also added a minor, trivial cleanup in
>>> patch 2 for consistency reasons.
>>>
>>
>> Looks good to me.
>
> Series applied, thanks.

Thanks a lot Pablo, as mentioned in [1], the _unchanged_ user space
part is available in [2].

Let me know if you want me to resend it, or if you would like to
take it from there.

Thanks,

Daniel

  [1] http://www.spinics.net/lists/netfilter-devel/msg29467.html
  [2] http://patchwork.ozlabs.org/patch/304826/
