From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH 1/8] sysfs: Implement sysfs tagged directory support.
Date: Thu, 04 Sep 2008 08:44:49 +0200
Message-ID: <48BF83E1.5040000@bull.net>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>	 <m1zloyh2mb.fsf_-_@frodo.ebiederm.org>	 <m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>	 <20080820021754.GA25182@kroah.com>	 <m1od3m282j.fsf_-_@frodo.ebiederm.org>	 <m1hc9e27ya.fsf_-_@frodo.ebiederm.org> <48B57058.9000101@bull.net>	 <dac45060809020654g62afb3c9yd104682b93b43bee@mail.gmail.com>	 <48BD47A8.1080909@bull.net> <20080902170148.GA9305@suse.de> <31436f4a0809032233r2c46de8od8a94460ce3b5ed2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	Mark Ryden <markryde@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50044 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbYIDGtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 02:49:51 -0400
In-Reply-To: <31436f4a0809032233r2c46de8od8a94460ce3b5ed2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Shwatrz wrote:
> Hi,
>> go into my tree this week,
> 
> I am also interested in this patch; may I ask  - what do you mean by
> "my  tree" ?I am a little newbie in the kernel, as you might understand.
> I looked into http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/
> for candidates for this git tree you are talking about.
> 
>  May I ask: what is the **exact** URL for this git tree you are talking about ?

Greg's tree is there:
http://git.kernel.org/?p=linux/kernel/git/gregkh/patches.git;a=summary

You can clone it from here:
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/patches.git

It contains the patches serie to be applied on top of
linux-2.6 (with 'quilt' for example).

Benjamin

> 
> Thanks,
> 
> Regards,
> DS
> 
> 
> On Tue, Sep 2, 2008 at 8:01 PM, Greg KH <gregkh@suse.de> wrote:
>> On Tue, Sep 02, 2008 at 04:03:20PM +0200, Benjamin Thery wrote:
>>> Mark Ryden wrote:
>>>> Hello,
>>>>  I hope that this patch (from 4.7.08) was not forgetten... I don't see
>>>> it for example in linux-net (I have an up-to-date linux-next git
>>>> tree).
>>> I was about to ask the same thing.
>>>
>>> Greg, what is the plan with these remaining patches for sysfs tagged
>>> dirs? Will you have some time to merge them in your tree soon?
>> Yes, they should go into my tree this week, sorry been busy with 2.6.27
>> work and Novell's Hackweek.
>>
>> thanks,
>>
>> greg k-h
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
