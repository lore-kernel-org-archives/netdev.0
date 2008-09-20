From: David Miller <davem@davemloft.net>
Subject: Re: [V#2 PATCH 0/18] netdevice: Fix directly reference of
 netdev->priv
Date: Sat, 20 Sep 2008 03:37:00 -0700 (PDT)
Message-ID: <20080920.033700.257291582.davem@davemloft.net>
References: <48C0A219.2030004@cn.fujitsu.com>
	<48D4B1B0.2030803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751320AbYITKhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 06:37:12 -0400
In-Reply-To: <48D4B1B0.2030803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Sat, 20 Sep 2008 16:17:52 +0800

> Dave said:
> > I'll see what I can do.
> > 
> > I know this is going to create conflicts in a few places, including sparc-next-2.6
> > where I already made this fix while cleaning up all of the SBUS device drivers.
> > 
> > So I guess I'm saying that I'm being lazy. :)
> > 
> > I'll try to look into this next week as I'm going to be busy and also away for
> > a few days.
> > 
> 
> Dave, seems nobody give any opposite comments.

Actually, I did see such comments which is why I totally dropped this set from
my inbox.  Besides, it's Jeff's territory technically :-)
