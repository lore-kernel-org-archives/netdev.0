From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 00/04] pull request for 'upstream-jeff' branch
Date: Mon, 29 Oct 2007 05:48:47 -0400
Message-ID: <4725AC7F.8090307@garzik.org>
References: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43895 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752993AbXJ2Jsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 05:48:50 -0400
In-Reply-To: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from branch 'upstream-jeff' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git upstream-jeff
> 
> to get the changes below.
> 
> Distance from 'master' (96fd4cd3e40e240f0c385af87f58e74da8b7099a)
> -----------------------------------------------------------------
> 
> d1417862d7355f0b395d83f2884afd614b086695
> bbd82f956e0db6190b16a8a00d3ed5d979f488e8
> 93dd79e87bbc98ef02610d54fe72d4a1931ee15e
> 7fab06c0ca89d99442a4baeddf417add585e2672
> 
> Diffstat
> --------
> 
>  drivers/net/Kconfig |   13 +++++++------
>  drivers/net/r8169.c |   12 ++++++------
>  2 files changed, 13 insertions(+), 12 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu (2):
>       ipg: missing Kconfig dependency
>       ipg: Kconfig whitepaces/tab damages
> 
> Stephen Hemminger (2):
>       r8169: napi config
>       r8169: remove poll_locked logic

pulled


