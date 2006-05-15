From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] SECMARK 1.1
Date: Mon, 15 May 2006 02:42:55 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605150242440.1900@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
 <Pine.LNX.4.64.0605140133560.5506@d.namei> <446778F0.6000705@trash.net>
 <Pine.LNX.4.64.0605150004590.645@d.namei> <446811D3.5080905@trash.net>
 <Pine.LNX.4.64.0605150153590.1275@d.namei> <446819FE.8050300@trash.net>
 <Pine.LNX.4.64.0605150221000.1275@d.namei> <44681F0F.9030601@trash.net>
 <Pine.LNX.4.64.0605150236270.1824@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>,
	Karl MacMillan <kmacmillan@tresys.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Bleher <bleher@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:44962 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932317AbWEOGm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 02:42:58 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <Pine.LNX.4.64.0605150236270.1824@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006, James Morris wrote:

> 
> Doh.  It should be try_module_get().  Sound ok?

Of course, I mean request_module().


-- 
James Morris
<jmorris@namei.org>
