From: Brad Campbell <brad@fnarfbargle.com>
Subject: Re: [Bug 40542] overflow/panic on KVM hipervizor
Date: Mon, 08 Aug 2011 09:40:47 +0800
Message-ID: <4E3F3E9F.2060704@fnarfbargle.com>
References: <bug-40542-28872@https.bugzilla.kernel.org/> <201108041733.p74HXrVp006413@demeter2.kernel.org> <4E3E9596.7090908@fnarfbargle.com> <4E3EAA84.7040708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, kvm@vger.kernel.org,
	slawek@rozbicki.eu, netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4E3EAA84.7040708@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/11 23:08, Avi Kivity wrote:
> On 08/07/2011 04:39 PM, Brad Campbell wrote:
>>
>> This looks like the bug I've been fighting with on and off.
>
> What's the bugzilla number for that?
>
> (unfortunately, no great insight except for "CLOSED DUPLICATE")
>
> hopefully someone from netdev can take a look, DNAT is seriously broken.
>
I can reproduce it at will, but it's on a live production machine. I've just ordered a second 
machine which I can use to reproduce and test against. From a bisection standpoint I'm about half 
way between 2.6.35 & 2.6.36, but until the second machine arrives I'm just unable to chase it any 
further.

Brad
