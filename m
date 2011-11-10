From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH v2] drivers/net/usb/asix: resync from vendor's copy
Date: Thu, 10 Nov 2011 15:17:26 -0500
Message-ID: <4EBC3156.2050409@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com> <20111026.194045.2019668159403582571.davem@davemloft.net> <4EA8B283.3010105@teksavvy.com> <20111026.221719.2216112919297458522.davem@davemloft.net> <4EB19BBE.5050602@teksavvy.com> <4EBAB8F5.1010101@teksavvy.com> <4EBBD936.40705@teksavvy.com> <CANEJEGuS1w_rPsjOfY8TqP=TewjRLSdEeR+OmaGB3G4LQZg82Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Michal Marek <mmarek@suse.cz>, Freddy Xin <freddy@asix.com.tw>,
	"ASIX Allan Email [office]" <allan@asix.com.tw>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport2-out.teksavvy.com ([206.248.154.181]:43180 "EHLO
	ironport2-out.pppoe.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752038Ab1KJUR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 15:17:28 -0500
In-Reply-To: <CANEJEGuS1w_rPsjOfY8TqP=TewjRLSdEeR+OmaGB3G4LQZg82Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-11-10 11:54 AM, Grant Grundler wrote:
> ...  and I was certain on their own, ASIX
> wouldn't get that upstream in one shot. No one knows them. No one
> trusts them. Asix never mentioned that they had already hired you to
> do it (and I am pretty sure you could have).

Just to clarify, ASIX did not contract me for any of this.
Rather, another of my clients requires working ASIX USB support,
and approved my working on that at their expense.

I've got working ASIX support now, just not in the mainline kernel.
The code is GPL, so we could stuff it in anyway,
but I think it would be better to do so with the
full cooperation of the nice folks at ASIX.

But for now, they seem happy to prefer feeding patches
only as requested, currently through Grant, rather than
trying to get the in-kernel driver brought fully up to date.

Cheers
