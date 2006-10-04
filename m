From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/2] [PATCH 0/2] Updated NetLabel/secid-reconciliation
 bits and a bugfix
Date: Wed, 4 Oct 2006 18:56:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610041855560.16024@d.namei>
References: <20061004154629.186531000@hp.com> <Pine.LNX.4.64.0610041439050.6196@d.namei>
 <45240369.4030107@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	sds@tycho.nsa.gov, vyekkirala@TrustedCS.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:43904 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751211AbWJDW4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 18:56:23 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <45240369.4030107@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2006, Paul Moore wrote:

> > So, patch 2/2 should go in on it's own against upstream?  If so, in 5B
> > future, please post such patches separately.
> 
> Yes, please commit patch 2/2 regardless as it fixes a bug which is not
> dependent on any of the secid patches which are being discussed.  My
> apologies for including it in the same patchset, I'll be sure to split
> it up next time.

Applied.

http://git.infradead.org/?p=users/jmorris/selinux-2.6.git

(This repo may move soon).


-- 
James Morris
<jmorris@namei.org>
