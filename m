From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for 'jg-20061009-00' tag
Date: Wed, 11 Oct 2006 04:47:58 -0400
Message-ID: <452CAFBE.9010603@garzik.org>
References: <20061009202133.GA18466@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, dragoran@feuerpokemon.de,
	ranma+kernel@tdiedrich.de, hchacha@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12929 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965180AbWJKIsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 04:48:07 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061009202133.GA18466@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from tag 'jg-20061009-00' in repository
>  
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git jg-20061009-00
> 
> to get the changes below.
> 
> Distance from 'upstream-fixes'
> -----------------------------
> 
> $ git rev-list 2f614fe04f4463ff22234133319067d7361f54e5..jg-20061009-00
> 91a6ba7162852092080b0e710dc0ba0f35496308
> 73f5e28b336772c4b08ee82e5bf28ab872898ee1
> 
> Diffstat
> --------
> 
>  drivers/net/forcedeth.c |   43 +++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/r8169.c     |    1 +
>  2 files changed, 44 insertions(+), 0 deletions(-)

I merged the forcedeth change via another source.  Could I pull from a 
tag with just the r8169 change?

	Jeff



