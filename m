From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: Re: [PATCH v3b 1/3] tipc: cosmetic: clean up comments and break a long line
Date: Wed, 01 May 2013 19:56:30 +0200
Message-ID: <5181574E.8060909@keymile.com>
References: <1367426477-10441-1-git-send-email-gerlando.falauto@keymile.com> <20130501.131602.899596493606702378.davem@davemloft.net>
	 <5181524D.6000207@keymile.com> <20130501.134356.491039302692790983.davem@davemloft.net>
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
Received: from mail.ch.keymile.com ([193.17.201.103]:45465 "HELO
	mail-ch.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752025Ab3EAR4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 13:56:38 -0400
In-Reply-To: <20130501.134356.491039302692790983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 05/01/2013 07:43 PM, David Miller wrote:
> From: Gerlando Falauto <gerlando.falauto@keymile.com>
> Date: Wed, 01 May 2013 19:35:09 +0200
>
>> That I don't understand. I thought it would be the other way around,
>> that's why I resubmitted only the one which changed.
>
> Any patch you submit I assume you test applied yourself successfully,
> therefore by submitting it you are saying that you validated them
> as a series explicitly or know that the other patches have no conflicts.

I understand, you're right. I hope adding "Changes from v(n-1): None" 
should also be enough to say that further review should not be necessary 
as the patch is identical to the previous version.

> Also, please never submit new versions of patches in replies to older
> patch discussions.
>
> Chain replies in order to construct a series are OK, especially when
> you provide a proper "[PATCH 0/N] ..." initial posting explaining
> the series.
>

OK, thanks.
Gerlando
