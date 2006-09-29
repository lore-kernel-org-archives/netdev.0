From: Paul Moore <paul.moore@hp.com>
Subject: Re: [MLSXFRM] Fix mis-labelling of child sockets
Date: Fri, 29 Sep 2006 18:29:50 -0400
Message-ID: <451D9E5E.5070302@hp.com>
References: <1159564681.3309.431.camel@pmac.infradead.org> <Pine.LNX.4.64.0609291738000.9262@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, torvalds@osdl.org, akpm@osdl.org,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	James Morris <jmorris@redhat.com>,
	Venkat Yekkirala <vyekkirala@trustedcs.com>,
	Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:48267 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S932085AbWI2W3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 18:29:52 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0609291738000.9262@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 29 Sep 2006, David Woodhouse wrote:
> 
> 
>>Accepted connections of types other than AF_INET, AF_INET6, AF_UNIX
>>won't have an appropriate label derived from the peer, so don't use it.
>>
>>Signed-off-by: David Woodhouse <dwmw2@infradead.org>
>>Acked-by:  Stephen Smalley <sds@tycho.nsa.gov>
> 
> 
> Acked-by: James Morris <jmorris@namei.org>
> 
> 
> Please apply as a bugfix.
> 

Sorry for the late response.

Acked-by: Paul Moore <paul.moore@hp.com>

-- 
paul moore
linux security @ hp
