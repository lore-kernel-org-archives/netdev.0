From: James Morris <jmorris@namei.org>
Subject: Re: [RFC][PATCH 1/3] net/ipv4: UDP-Lite extensions
Date: Wed, 23 Aug 2006 15:45:14 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608231544270.5573@d.namei>
References: <200608231150.42039@strip-the-willow> <Pine.LNX.4.64.0608231019010.3198@d.namei>
 <200608231603.08240@strip-the-willow> <Pine.LNX.4.64.0608231112530.3870@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, alan@lxorguk.ukuu.org.uk,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, kaber@coreworks.de,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965154AbWHWTpV@vger.kernel.org>
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <Pine.LNX.4.64.0608231112530.3870@d.namei>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006, James Morris wrote:

> continue executing.  Although, it's not entirely clear how to determine 
> this, e.g. perhaps the system should panic if netfilter initialization 
> failed, as it might mean that the systems comes up without a firewall.

Actually, I guess it's up to userspace to figure this out.



- James
-- 
James Morris
<jmorris@namei.org>
