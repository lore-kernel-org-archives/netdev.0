From: "Mark Ryden" <markryde@gmail.com>
Subject: Re: [PATCH 1/8] sysfs: Implement sysfs tagged directory support.
Date: Tue, 7 Oct 2008 18:39:04 +0200
Message-ID: <dac45060810070939v80918a0m3963d7fc6fcbb975@mail.gmail.com>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	 <20080820021754.GA25182@kroah.com>
	 <m1od3m282j.fsf_-_@frodo.ebiederm.org>
	 <m1hc9e27ya.fsf_-_@frodo.ebiederm.org> <48B57058.9000101@bull.net>
	 <dac45060809020654g62afb3c9yd104682b93b43bee@mail.gmail.com>
	 <48BD47A8.1080909@bull.net> <20080902170148.GA9305@suse.de>
	 <31436f4a0809032233r2c46de8od8a94460ce3b5ed2@mail.gmail.com>
	 <48BF83E1.5040000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Shwatrz" <dshwatrz@gmail.com>, "Greg KH" <gregkh@suse.de>,
	"Greg KH" <greg@kroah.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Tejun Heo" <htejun@gmail.com>,
	"Daniel Lezcano" <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, "Al Viro" <viro@ftp.linux.org.uk>,
	"Linux Containers" <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Benjamin Thery" <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:50515 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbYJGQjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 12:39:06 -0400
Received: by gxk9 with SMTP id 9so6815881gxk.13
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2008 09:39:05 -0700 (PDT)
In-Reply-To: <48BF83E1.5040000@bull.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
  So I wonder: the sysfs tagged directory support patch is in GerKH
tree for more than a month.
I cloned today latest Linus tree (2.6.27-rc9) and
it is not there as far as I can see.
It is also not in linux-next tree (from september).
Now, I wonder what is the process of merging this
GregKH tree ? should I watch the LKML list for a pull request
from GregKH? or will it be first merged into the linux-next tree?

Regards,
Mark


On Thu, Sep 4, 2008 at 8:44 AM, Benjamin Thery <benjamin.thery@bull.net> wrote:
> David Shwatrz wrote:
>>
>> Hi,
>>>
>>> go into my tree this week,
>>
>> I am also interested in this patch; may I ask  - what do you mean by
>> "my  tree" ?I am a little newbie in the kernel, as you might understand.
>> I looked into
>> http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/
>> for candidates for this git tree you are talking about.
>>
>>  May I ask: what is the **exact** URL for this git tree you are talking
>> about ?
>
> Greg's tree is there:
> http://git.kernel.org/?p=linux/kernel/git/gregkh/patches.git;a=summary
>
> You can clone it from here:
> git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/patches.git
>
> It contains the patches serie to be applied on top of
> linux-2.6 (with 'quilt' for example).
>
> Benjamin
>
>>
>> Thanks,
>>
>> Regards,
>> DS
>>
>>
>> On Tue, Sep 2, 2008 at 8:01 PM, Greg KH <gregkh@suse.de> wrote:
>>>
>>> On Tue, Sep 02, 2008 at 04:03:20PM +0200, Benjamin Thery wrote:
>>>>
>>>> Mark Ryden wrote:
>>>>>
>>>>> Hello,
>>>>>  I hope that this patch (from 4.7.08) was not forgetten... I don't see
>>>>> it for example in linux-net (I have an up-to-date linux-next git
>>>>> tree).
>>>>
>>>> I was about to ask the same thing.
>>>>
>>>> Greg, what is the plan with these remaining patches for sysfs tagged
>>>> dirs? Will you have some time to merge them in your tree soon?
>>>
>>> Yes, they should go into my tree this week, sorry been busy with 2.6.27
>>> work and Novell's Hackweek.
>>>
>>> thanks,
>>>
>>> greg k-h
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>
>
> --
> B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D
>
>   http://www.bull.com
>
