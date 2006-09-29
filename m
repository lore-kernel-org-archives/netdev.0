From: James Morris <jmorris@namei.org>
Subject: Re: [MLSXFRM] Fix mis-labelling of child sockets
Date: Fri, 29 Sep 2006 17:38:28 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609291738000.9262@d.namei>
References: <1159564681.3309.431.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: torvalds@osdl.org, akpm@osdl.org, netdev@vger.kernel.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Paul Moore <paul.moore@hp.com>,
	James Morris <jmorris@redhat.com>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:57261 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1422828AbWI2Vic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:38:32 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1159564681.3309.431.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006, David Woodhouse wrote:

> Accepted connections of types other than AF_INET, AF_INET6, AF_UNIX
> won't have an appropriate label derived from the peer, so don't use it.
> 
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>

Acked-by: James Morris <jmorris@namei.org>


Please apply as a bugfix.



-- 
James Morris
<jmorris@namei.org>
