From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/16] mib: finish with ipv4 mibs netnsization
Date: Mon, 21 Jul 2008 17:24:29 -0700
Message-ID: <m1prp6lq9u.fsf@frodo.ebiederm.org>
References: <487F46CD.7090103@openvz.org>
	<20080718.040925.261545164.davem@davemloft.net>
	<4884C9AD.4040608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44914 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837AbYGVAca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 20:32:30 -0400
In-Reply-To: <4884C9AD.4040608@openvz.org> (Pavel Emelyanov's message of "Mon,
	21 Jul 2008 21:38:53 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

> David Miller wrote:
>> 
>> I keep hearing noises that some day sysfs+ns will work, is that something
>> we'll see in 2.6.27 possibly?  
>
> Unfortunately not in 2.6.27 :( Eric send sysfs-for-namespaces patchset
> 2 or 3 weeks ago, but Greg was going for vacation that time.

Yes the timing has been bad all around.  But finally Tejun and
I agree on a patchset that will work, and Greg doesn't have a problem
putting it in his tree for post 2.6.27.

>> That would help my own build validation and testing of changes.

It currently looks like these changes will show up in the first
round of linux-next.  My apologies for the delay.  Untangling
the knot that is sysfs is a challenge.

Eric
