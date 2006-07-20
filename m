From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] via-velocity: fix reported speed and link detected status
Date: Thu, 20 Jul 2006 23:57:28 +0200
Message-ID: <20060720215728.GA32119@electric-eye.fr.zoreil.com>
References: <20060720032854.GA4520@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49120 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1030388AbWGTV76
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 17:59:58 -0400
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <20060720032854.GA4520@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn <jacliburn@bellsouth.net> :
> The via-velocity driver reports incorrect speed and link detected status
> as viewed by ethtool (and probably other tools). This patch fixes those
> incorrect reports and prettifies a long line.

Looks fine.

Fixed the whitespace/tabs damage, the 190 cols comment  and taged as
'upstream-20060720-00' in branch 'upstream' at
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

-- 
Ueimor
