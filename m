From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC v2] netfilter: xt_condition: add condition target
Date: Tue, 20 Jul 2010 13:46:01 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007201343470.3843@obet.zrqbmnf.qr>
References: <1279619434-11849-1-git-send-email-luciano.coelho@nokia.com>  <alpine.LSU.2.01.1007201235250.20447@obet.zrqbmnf.qr>  <1279623855.16431.4.camel@powerslave>  <alpine.LSU.2.01.1007201308370.526@obet.zrqbmnf.qr>
 <1279625526.16431.22.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279625526.16431.22.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2010-07-20 13:32, Luciano Coelho wrote:
>it in any archives).  Then a few days ago I asked you if you were going
>to resend and you answered:
>
>On Fri, 2010-07-16 at 13:20 +0200, ext Jan Engelhardt wrote:
>> On Friday 2010-07-16 13:10, Luciano Coelho wrote:
>> >Are you planning to resend this patch with the changes Patrick
>> >suggested?
>> 
>> I can try. 
>
>So I assumed you would resubmit it for upstream inclusion.  I probably
>misunderstood something in the way then ;)

It usually means "I'll do it .... unless someone else does first".
Since you proposed the condition target, you nicely took all of
xt_condition into your hands. Or as Linus once put it:
"they are doing all the work, and I get the credit". :-)

>> Just be sure to have condition plus its 32-bit upgrade patch merged at
>> the same time.
>
>I think the best idea will be to send a patchset with the three patches
>at once (original xt_condition, plus the target patch, plus the 32-bit
>patch).

Fine by me.
