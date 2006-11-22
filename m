From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 01:43:51 -0700
Message-ID: <m1wt5nub08.fsf@ebiederm.dsl.xmission.com>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru>
	<45633EDF.3050309@fr.ibm.com> <200611221121.59322.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Kirill Korotaev <dev@sw.ru>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756978AbWKVIox@vger.kernel.org>
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200611221121.59322.dim@openvz.org> (Dmitry Mishin's message of
	"Wed, 22 Nov 2006 11:21:58 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin <dim@openvz.org> writes:

> On Tuesday 21 November 2006 21:01, Daniel Lezcano wrote:
>> Kirill Korotaev wrote:
>> > Cedric,
>> >
>> > Dmitry Mishin and Daniel Lezcano are working together on the full
>> > network namespace incorporating both needs of OpenVZ and VServer/IBM.
>> >
>> > Thanks,
>> > Kirill
>>
>> Kirill,
>>
>> We will need this framework to move the network isolation code to the
>> ns_proxy/net_namespace structure. So if Cedric gives us a empty
>> framework it is fine, except if someone does not agree with it...
>>
>>    -- Daniel.
> This patch looks acceptable for us.
> BTW, Daniel, we agreed to be based on the Andrey's patchset. I do not see a 
> reason, why Cedric force us to make some unnecessary work and move existent 
> patchset over his interface.

If you are going to take that attitude.  Where was this conversation?

It appears several relevant people were not aware of this development
discussion.  So when it comes up for general review you can expect your
approach as well as your code to be critiqued.

Eric
