From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH RESEND 2/3] netfilter: xt_condition: change the value
 from boolean to u32
Date: Tue, 21 Sep 2010 23:00:50 +0300
Message-ID: <1285099250.10579.18.camel@powerslave>
References: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com>
	 <1282034213-1829-3-git-send-email-luciano.coelho@nokia.com>
	 <4C912F84.9030809@trash.net>
	 <alpine.LNX.2.01.1009152246180.5146@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>,
	"Ylalehto Janne (Nokia-MS/Tampere)" <janne.ylalehto@nokia.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1009152246180.5146@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-15 at 22:46 +0200, ext Jan Engelhardt wrote:
> On Wednesday 2010-09-15 22:41, Patrick McHardy wrote:
> 
> >Am 17.08.2010 10:36, schrieb Luciano Coelho:
> >>  static struct xt_match condition_mt_reg __read_mostly = {
> >>  	.name       = "condition",
> >> -	.revision   = 1,
> >> +	.revision   = 2,
> >
> >Is this previous version actually compatible with anything that has
> >ever been released?
> 
> Yes, rev1 is used by Xtables-addons.

Indeed.  It was Jan who recommended this to be changed to 2 to avoid
conflict with Xtables-addons.


-- 
Cheers,
Luca.

