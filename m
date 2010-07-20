From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC v2] netfilter: xt_condition: add condition target
Date: Tue, 20 Jul 2010 13:11:42 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007201308370.526@obet.zrqbmnf.qr>
References: <1279619434-11849-1-git-send-email-luciano.coelho@nokia.com>  <alpine.LSU.2.01.1007201235250.20447@obet.zrqbmnf.qr> <1279623855.16431.4.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: Luciano Coelho <luciano.coelho@Nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279623855.16431.4.camel@powerslave>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2010-07-20 13:04, Luciano Coelho wrote:
>
>Yes, I made this patch on top of the one you have sent earlier for
>upstream inclusion.  There were some comments from Patrick to that one
>and, as I said in my email yesterday, I'll rebase the target patches
>once the original one is included upstream.

The original one won't be - that is, basically you will be making the
initial upstream submission.
However, you are right; fabricating two patches is a good idea and
is in fact what I advertise too (xt_TEE discussion about specifying
oif..) - avoiding a singular huge patch is a best practice.
Just be sure to have condition plus its 32-bit upgrade patch merged at
the same time.

>Do you want me to take a look at Patrick's comments and resubmit the
>patch you've sent with the changes Patrick asked for?

Yes. Not obeying His Highness's wishes is a death nail for a module ;-)
