From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Rework dev_base via list_head (v2)
Date: Thu, 03 May 2007 16:52:23 +0200
Message-ID: <4639F727.8080100@trash.net>
References: <4639C95A.3030809@sw.ru> <4639CB11.2050508@trash.net> <4639F542.7010800@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Kirill Korotaev <dev@sw.ru>, devel@openvz.org
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64561 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162079AbXECOw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 10:52:59 -0400
In-Reply-To: <4639F542.7010800@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Patrick McHardy wrote:
> 
>>This seems to be missing fs/afs/netdevices.c.
>>
> 
> 
> Hm... I've cloned the git repo this morning but there's not such file...
> 
> $ ls fs/afs/netdevices.c
> /bin/ls: fs/afs/netdevices.c: No such file or directory
> 
> Repo was cloned from
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git


You need to update, its there in the current tree.
