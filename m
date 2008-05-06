From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Please pull for-2.6.26 branch of linux-2.6-mv643xx_eth.git
Date: Tue, 06 May 2008 12:23:39 -0400
Message-ID: <4820860B.6000705@pobox.com>
References: <20080429163452.GA21234@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@marvell.com>
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41437 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761995AbYEFQXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:23:42 -0400
In-Reply-To: <20080429163452.GA21234@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dale Farnsworth wrote:
> Hi Jeff,
> 
> The following changes since commit e31a94ed371c70855eb30b77c490d6d85dd4da26:
>   Linus Torvalds (1):
>     Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstream-linus
> 
> are available in the git repository at:
> 
>   git://git.farnsworth.org/dale/linux-2.6-mv643xx_eth.git for-2.6.26
> 
> Please pull.
> 
> Lennert Buytenhek (5):
>       mv643xx_eth: get rid of static variables, allow multiple instances
>       mv643xx_eth: mbus decode window support
>       mv643xx_eth: configurable t_clk
>       mv643xx_eth: shorten shared platform driver name
>       mv643xx_eth: inter-mv643xx SMI port sharing
> 
>  arch/arm/mach-orion5x/common.c            |    2 +
>  arch/powerpc/platforms/chrp/pegasos_eth.c |    4 +
>  arch/powerpc/sysdev/mv64x60_dev.c         |    2 +
>  arch/ppc/syslib/mv64x60.c                 |    3 +
>  drivers/net/mv643xx_eth.c                 |  160 ++++++++++++++++++++++-------
>  include/linux/mv643xx_eth.h               |   16 +++-
>  6 files changed, 148 insertions(+), 39 deletions(-)

pulled


