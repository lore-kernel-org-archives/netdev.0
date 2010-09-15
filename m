From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH RESEND 2/3] netfilter: xt_condition: change the value
 from boolean to u32
Date: Wed, 15 Sep 2010 22:46:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1009152246180.5146@obet.zrqbmnf.qr>
References: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com> <1282034213-1829-3-git-send-email-luciano.coelho@nokia.com> <4C912F84.9030809@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Luciano Coelho <luciano.coelho@nokia.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	sameo@linux.intel.com, janne.ylalehto@nokia.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C912F84.9030809@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-09-15 22:41, Patrick McHardy wrote:

>Am 17.08.2010 10:36, schrieb Luciano Coelho:
>>  static struct xt_match condition_mt_reg __read_mostly = {
>>  	.name       = "condition",
>> -	.revision   = 1,
>> +	.revision   = 2,
>
>Is this previous version actually compatible with anything that has
>ever been released?

Yes, rev1 is used by Xtables-addons.
