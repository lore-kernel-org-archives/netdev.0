From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 16:23:05 +0300
Message-ID: <45644F39.20402@sw.ru>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru>	<45633EDF.3050309@fr.ibm.com> <200611221121.59322.dim@openvz.org> <m1wt5nub08.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:12929 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1755776AbWKVNOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 08:14:34 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1wt5nub08.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>We will need this framework to move the network isolation code to the
>>>ns_proxy/net_namespace structure. So if Cedric gives us a empty
>>>framework it is fine, except if someone does not agree with it...
>>>
>>>   -- Daniel.
>>
>>This patch looks acceptable for us.
>>BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a 
>>reason, why Cedric force us to make some unnecessary work and move existent 
>>patchset over his interface.
> 
> 
> If you are going to take that attitude.  Where was this conversation?
> 
> It appears several relevant people were not aware of this development
> discussion.  So when it comes up for general review you can expect your
> approach as well as your code to be critiqued.

Eric,

Dim collected the requirements for all the network virtualization approaches:
http://wiki.openvz.org/Containers/Network_virtualization
This was discussed with Daniel and Herbert.

Dim and Daniel just wanted to prepare the patches for this.
So I hope your critique will be constructive as they do a hard job :)

Thanks,
Kirill

