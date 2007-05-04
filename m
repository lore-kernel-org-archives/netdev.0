From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How to find I/F to destination
Date: Fri, 4 May 2007 17:25:52 +0400
Message-ID: <20070504132552.GC2291@2ka.mipt.ru>
References: <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com> <7844.1178285004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50897 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755175AbXEDN0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:26:12 -0400
Content-Disposition: inline
In-Reply-To: <7844.1178285004@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 02:23:24PM +0100, David Howells (dhowells@redhat.com) wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > static int netchannel_ip_route_output_flow(struct rtable **rp, struct flowi *flp, int flags)
> 
> What's proto?  Should that be IPPROTO_UDP?

Yep.

> David

-- 
	Evgeniy Polyakov
