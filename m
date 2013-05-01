From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: Re: [PATCH v3b 1/3] tipc: cosmetic: clean up comments and break a long line
Date: Wed, 01 May 2013 19:35:09 +0200
Message-ID: <5181524D.6000207@keymile.com>
References: <51814058.3080805@cogentembedded.com> <1367426477-10441-1-git-send-email-gerlando.falauto@keymile.com> <20130501.131602.899596493606702378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
	"erik.hugne@ericsson.com" <erik.hugne@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"Brunck, Holger" <Holger.Brunck@keymile.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ch.keymile.com ([193.17.201.103]:43487 "HELO
	mail-ch.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752079Ab3EARfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 13:35:19 -0400
In-Reply-To: <20130501.131602.899596493606702378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 05/01/2013 07:16 PM, David Miller wrote:
> From: Gerlando Falauto <gerlando.falauto@keymile.com>
> Date: Wed,  1 May 2013 18:41:17 +0200
>
>> Signed-off-by: Gerlando Falauto <gerlando.falauto@keymile.com>
>> ---
>> Changes from v3:
>> * Added "and break a long line" to the commit message
>> Changes from v2:
>> * Split cosmetic (this patch) from functional changes (next patch)
>
> Never resubmit patches by themselves, always resubmit the entire series.

I was just wondering what happens in that case, thank you for the 
explanation, I had no idea.

>
> Because when one patch has problems, I toss the entire series from patchwork,

Is "v3b" good or shall I just use v4 instead?
Do I also need to change the version number (and add "Changes from 
previous version" lines) to the subsequent patches, even though nothing 
has actually changed)? Should have I used a cover letter to begin with?

 > and by resubmitting the entire series again you are also giving me 
important
 > information, you're telling me that the subsequent patches in the series
 > still apply cleanly even though the first one has changed.

That I don't understand. I thought it would be the other way around, 
that's why I resubmitted only the one which changed.
If I resubmit the entire series, how can you tell patches 2 and 3 are 
identical to the previous version I posted?

Last question: Is chain reply OK?

Thanks for your patience,
Gerlando


>
> I've tossed this patch too, resubmit this properly, thanks.
>
