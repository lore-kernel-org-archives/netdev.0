From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Thu, 29 Oct 2009 15:44:42 +0100
Message-ID: <14add3d10910290744n3abd1cf8w42a6311108eb2fa7@mail.gmail.com>
References: <200910291435.54203.bzolnier@gmail.com>
	 <200910291514.40318.bzolnier@gmail.com>
	 <20091029.072101.109209962.davem@davemloft.net>
	 <200910291539.16476.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, bzolnier@gmail.com,
	penberg@cs.helsinki.fi, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754897AbZJ2Ool@vger.kernel.org>
In-Reply-To: <200910291539.16476.mb@bu3sch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 29, 2009 at 3:39 PM, Michael Buesch <mb@bu3sch.de> wrote:
> On Thursday 29 October 2009 15:21:01 David Miller wrote:
>> The issue is that John disagrees with you can you can't handle
>> that.
>>
>> So instead of continuing to discuss things with him and the
>> other wireless folks, you want me to just overreach everybody
>> and revert someone else's work.
>
> In the end this results in the driver maintainer being forced to maintain
> code and handle bugreports for code that he disagrees with in the first place.
> This is unacceptable and has to be resolved in some way.
> If it's not possible to get it reverted through John (for whatever reason),
> you're in charge to help the actual code maintainer out.
>
>> I'm not going to do that sorry, learn how to work with the
>> wireless people instead.
>
> This is not the problem.
> The problem is that stuff is merged without ack from the maintainer
> and it's virtually impossible to get the stuff reverted. The only real
> way for the maintainer to resolve this is 1) live with it or 2) fix it.
> And that's bad, because it completely invalidates his priority queue.
>
> Just like you must not bypass John, the driver maintainers must not be bypassed, too.
> The quality control does _only_ work if nobody in the chain is bypassed.
> But in this situation the quality control did already fail and it should be
> tried hard to resolve (=revert) the situation instead of pointing at John.
>

Hold on here. In this case it is the driver maintainer (i.e. Ivo for
the rt2x00 project) that
submitted this driver for inclusion, so the driver maintainer has not
been bypassed in
this case.

Apparently Bart has issues with the code submitted by the maintainers
and has been
unsuccessful in convincing others about these issues.

---
Gertjan.
