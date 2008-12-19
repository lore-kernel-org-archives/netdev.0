From: "David Schwartz" <davids@webmaster.com>
Subject: RE: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 16:45:32 -0800
Message-ID: <MDEHLPKNGKAHNMBLJOLKKEJJBPAD.davids@webmaster.com>
References: <1229641573.3726.563.camel@calx>
Reply-To: davids@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753958AbYLSAqo@vger.kernel.org>
In-Reply-To: <1229641573.3726.563.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Most people won't actually think their printer is on fire. But most
> people WILL think there is serious cause for concern when they see this
> for the first time in dmesg. Many will search the net for explanations
> and come away confused and not entirely reassured. And at least one
> clueless guy will call the police because he still thinks he's under
> attack.

Messages about something or other being "illegal" occur about 345 times in
the Linux kernel source code. Are we going to start patching those too?

We have "illegal norm", "illegal input", "illegal call", "illegal type",
"illegal bits", "illegal root port number", "illegal host number", "illegal
DMA data", "illegal dimensions" (who do you call about that one?), "illegal
phase", "illegal page number", "illegal seek", and on, and on, and on.

I suspect that if I submitted a patch to change all of those to "invalid",
I'd be considered a kook. (Well, more of a kook, anyway.)

DS
