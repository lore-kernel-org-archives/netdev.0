From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 26 Feb 2010 13:42:06 -0800
Message-ID: <m13a0nwu6p.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>
	<m1bpfbwuze.fsf@fess.ebiederm.org> <4B883E6F.1060907@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B883E6F.1060907@parallels.com> (Pavel Emelyanov's message of "Sat\, 27 Feb 2010 00\:34\:39 +0300")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@parallels.com> writes:

>>> Yet another set of per-namespace IDs along with CLONE_NEWXXX ones?
>>> I currently have a way to create all namespaces we have with one
>>> syscall. Why don't we have an ability to enter them all with one syscall?
>> 
>> The CLONE_NEWXXX series of bits has been an royal pain to work with,
>> and it appears to be unnecessary complications for no gain.
>
> That's the answer for the "Yet another set..." question.
> How about the "Why don't we have..." one?

I am not certain which question you are asking:

Why don't we have an ability to enter all namespaces with one syscall
invocation?

Why don't we have a syscall that allows us to enter every namespace?

Eric

