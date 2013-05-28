From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Fix the SELinux dynamic network access controls
Date: Mon, 27 May 2013 23:31:42 -0700 (PDT)
Message-ID: <20130527.233142.1355482811896259082.davem@davemloft.net>
References: <20130524181430.24022.15997.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, omoris@redhat.com,
	pwouters@redhat.com
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008Ab3E1Gbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:31:43 -0400
In-Reply-To: <20130524181430.24022.15997.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 24 May 2013 14:16:16 -0400

> A bump to v2 to incorporate Sergei's minor comment on the previous
> patchset.  I've also gone ahead and dropped the "RFC" from the
> patchset as I didn't see any significant comments/concerns from
> anyone.

Genuine bug fixes should be targetted at 'net' and not be mixed with
random other cleanup, janitorial, etc. changes that belong in 'net-next'
only.
