From: Jonas Bonn <jonas@southpole.se>
Subject: Re: Lockdep warning
Date: Thu, 19 Dec 2013 15:04:37 +0100
Message-ID: <52B2FCF5.40601@southpole.se>
References: <52B2F668.2030400@southpole.se> <20131219140221.GA27143@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:46117 "EHLO mail.southpole.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754269Ab3LSOEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 09:04:40 -0500
In-Reply-To: <20131219140221.GA27143@pd.tnic>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 03:02 PM, Borislav Petkov wrote:
> On Thu, Dec 19, 2013 at 02:36:40PM +0100, Jonas Bonn wrote:
>
> In such situations I'd always search the net first, to see whether this
> has been fixed already. Hint: try searching for "lockdep __udp4_lib_rcv"

Ah... my bad.  Thanks!

Sorry for the noise.

/Jonas
