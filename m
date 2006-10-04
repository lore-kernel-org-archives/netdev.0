From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/2] [PATCH 0/2] Updated NetLabel/secid-reconciliation
 bits and a bugfix
Date: Wed, 4 Oct 2006 14:44:03 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610041439050.6196@d.namei>
References: <20061004154629.186531000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	sds@tycho.nsa.gov, vyekkirala@TrustedCS.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:38023 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1422733AbWJDSoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 14:44:05 -0400
To: paul.moore@hp.com
In-Reply-To: <20061004154629.186531000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2006, paul.moore@hp.com wrote:

> This patchset includes an update to the NetLabel/secid-reconciliation patch,
> replacing my "v3" patch from earlier this week, and a bugfix patch to cure a
> race condition found during testing this week.  The bugfix patch does not
> rely on the secid patches and should be merged regardless as it fixes a bug
> which has been around since the very first NetLabel patches (not sure why I
> didn't see this sooner).

So, patch 2/2 should go in on it's own against upstream?  If so, in 5B
future, please post such patches separately.

As for the rest of the network labeling, please work together with Venkat 
and the SELinux developers on a final patchset which meets all of the 
design goals and has been tested, with policy which has been merged 
upstream and is available via Fedora devel.  Please keep the discussion 
going, but ensure that the final patchset for review and merge 
consideration is a complete set against the current git kernel coming from 
one person.

Thanks,



- James
-- 
James Morris
<jmorris@namei.org>
