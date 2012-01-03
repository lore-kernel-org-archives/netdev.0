From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: proper detection of libxtables position and flags
Date: Tue, 3 Jan 2012 13:47:19 -0800
Message-ID: <20120103134719.414ae3d0@nehalam.linuxnetplumber.net>
References: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46805 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125Ab2ACVrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 16:47:23 -0500
In-Reply-To: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Dec 2011 23:17:56 +0100 (CET)
Jan Engelhardt <jengelh@medozas.de> wrote:

> From: Jan Engelhardt <jengelh@medozas.de>
> Date: 2011-09-24 23:37:34.405739159 +0200
> Upstream: not sent yet
> 
> Any tests involving iptables _MUST_ utilize pkg-config to find the
> proper locations of the installation. 
> 

Will this work for all distros? Is this backwards compatiable?
