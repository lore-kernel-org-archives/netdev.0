From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sun, 10 Dec 2006 01:52:27 +0000
Message-ID: <20061210015227.GZ4587@ftp.linux.org.uk>
References: <20061208.164345.71119524.davem@davemloft.net> <20061208.171455.11932070.davem@davemloft.net> <20061209103953.GN8693@postel.suug.ch> <20061209.134552.71105673.davem@davemloft.net> <5b2e36650612091742u70188d90l25e91c33468a0c0a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch, drow@false.org,
	stefan@loplof.de, dwmw2@infradead.org, joseph@codesourcery.com,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46505 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759218AbWLJBwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 20:52:54 -0500
To: Jeff Bailey <jbailey@raspberryginger.com>
Content-Disposition: inline
In-Reply-To: <5b2e36650612091742u70188d90l25e91c33468a0c0a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 09, 2006 at 08:42:45PM -0500, Jeff Bailey wrote:
> On 09/12/06, David Miller <davem@davemloft.net> wrote:
> >You can't deprecate stuff visible to userspace, sorry Thomas,
> >we just can't do it.
> >
> >You can migrate people to "better" interfaces, but you can't
> >pull the rug out from anyone once things like this are visible
> >to userspace.  It's permanently there, and we have to live with
> >that.
> 
> Is there some way of marking it so that newer architectures that come
> on don't wind up with that export?  That way at least as newer
> machines and arches come out, they don't have to carry the oldest
> baggage.  As the oldest architectures eventually get dropped, cruft
> can be removed.

Which architectures ever got dropped?
