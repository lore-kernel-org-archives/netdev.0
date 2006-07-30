From: James Morris <jmorris@namei.org>
Subject: Re: [-mm patch] security/selinux/hooks.c: make 4 functions static
Date: Sat, 29 Jul 2006 20:37:09 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607292036460.31683@d.namei>
References: <20060727015639.9c89db57.akpm@osdl.org> <20060729174830.GD26963@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:48875 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750896AbWG3AhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 20:37:13 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060729174830.GD26963@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006, Adrian Bunk wrote:

> On Thu, Jul 27, 2006 at 01:56:39AM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.18-rc2-mm1:
> >...
> >  git-net.patch
> >...
> >  git trees
> >...
> 
> This patch makes four needlessly global functions static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>


Acked-by: James Morris <jmorris@namei.org>




-- 
James Morris
<jmorris@namei.org>
