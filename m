From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: Blackfin Ethernet MAC driver compile error
Date: Fri, 05 Oct 2007 00:31:17 +0800
Message-ID: <1191515477.6361.3.camel@roc-laptop>
References: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
	 <1191489141.6139.1.camel@roc-laptop>
	 <a425f86c0710040726q27aeb354vbbcb68bd2fed2b76@mail.gmail.com>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Pokki <kalle.pokki@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:28082 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755585AbXJDQbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 12:31:24 -0400
In-Reply-To: <a425f86c0710040726q27aeb354vbbcb68bd2fed2b76@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-10-04 at 22:26 +0800, Kalle Pokki wrote:
> On 10/4/07, Bryan Wu <bryan.wu@analog.com> wrote: 
> > Sorry for missing the pinmux patches. 
> > After Linus's git-pull, it should be fixed in the latest Linus
> mainline 
> > git tree.
> 
> Thanks, it is working now. I was also glad to see the binfmt_flat 
> patch going in.

Yeah, thanks Linus to accept the patches 
> 
> Do you plan to get the PHY abstraction layer patches for the Blackfin 
> EMAC included in the upcoming merge window?

Currently, it is in Jeff's netdev-2.6.git tree. IMO, Jeff will send it
to Linus when merge window open.

Regards
-Bryan Wu
> 
