From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 4 Jun 2007 15:44:48 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0706041544230.13341@d.namei>
References: <200703262321.l2QNLZlR014240@faith.austin.ibm.com>
 <1180983953.3950.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, selinux@tycho.nsa.gov,
	Joy Latten <latten@austin.ibm.com>
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:39560 "EHLO
	mail7.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758966AbXFDTow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 15:44:52 -0400
In-Reply-To: <1180983953.3950.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 4 Jun 2007, Eric Paris wrote:

> Some time ago this thread bounced back and forth and seemed to come to
> rest with the patch below, I cleaned up the comments and put all the
> ACKs it received in one place below, but so much time has passed I doubt
> if they should still count for free.  I also rediffed the patch against
> the latest miller tree.  Is the idea or patch in any way flawed or
> unacceptable to people at the moment?
> 
> Anyone willing to step up an re-ack the patch to get it moving into the
> tree?

Looks good to me.

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
