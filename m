From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] forcedeth: fix random memory scribbling bug
Date: Sat, 24 Dec 2005 11:57:48 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0512241155250.14098__12989.5490514629$1135454367$gmane$org@g5.osdl.org>
References: <43AD4ADC.8050004@colorfullife.com> <43AD64AB.2070306@pobox.com>
 <43AD726A.5010703@colorfullife.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, Ayaz Abdulla <AAbdulla@nvidia.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <43AD726A.5010703@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sat, 24 Dec 2005, Manfred Spraul wrote:
> 
> > 2) I have requested multiple times that you avoid MIME...
> 
> It's the first time that you complain about Content-Transfer-Encoding: 7bit
> attachments.

These proper text encodings are easy to _apply_, because the raw email is 
uncorrupted. 

However, attachments are still broken for a very fundamental reason: 
basically no email client will ever quote them on replies. Which means 
that if somebody has commentary about some specific part of the patch, the 
attachement is _totally_ the wrong thing to do.

In other words, there's a reason I encourage people VERY STRONGLY to use 
in-line patches. If you have a broken mailer that corrupts whitespace, 
please just fix it.

		Linus
