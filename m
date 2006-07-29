From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] via-velocity: fix reported speed and link detected status
Date: Sat, 29 Jul 2006 01:26:59 -0400
Message-ID: <44CAF1A3.3010809@pobox.com>
References: <20060720032854.GA4520@osprey.hogchain.net> <20060720215728.GA32119@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:17828 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161419AbWG2F1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 01:27:06 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060720215728.GA32119@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jay Cliburn <jacliburn@bellsouth.net> :
>> The via-velocity driver reports incorrect speed and link detected status
>> as viewed by ethtool (and probably other tools). This patch fixes those
>> incorrect reports and prettifies a long line.
> 
> Looks fine.
> 
> Fixed the whitespace/tabs damage, the 190 cols comment  and taged as
> 'upstream-20060720-00' in branch 'upstream' at
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

pulled


