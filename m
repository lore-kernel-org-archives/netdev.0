From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Apr 23 (phonet sysctl)
Date: Mon, 23 Apr 2012 09:38:48 -0700
Message-ID: <4F958598.6080305@xenotime.net>
References: <20120423170701.c96e402234b1387dece11dda@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy9.bluehost.com ([69.89.24.6]:51807 "HELO
	oproxy9.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752193Ab2DWQiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 12:38:18 -0400
In-Reply-To: <20120423170701.c96e402234b1387dece11dda@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2012 12:07 AM, Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20120420:



ERROR: "unregister_net_sysctl_table" [net/phonet/phonet.ko] undefined!
ERROR: "register_net_sysctl" [net/phonet/phonet.ko] undefined!

when CONFIG_SYSCTL is not enabled.

-- 
~Randy
