From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AFS: Fix use of __exit functions from __init path
Date: Thu, 03 May 2007 03:12:56 -0700 (PDT)
Message-ID: <20070503.031256.41677663.davem@davemloft.net>
References: <20070501181706.28008.10566.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	geert@linux-m68k.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59100
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752854AbXECKMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:12:55 -0400
In-Reply-To: <20070501181706.28008.10566.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 01 May 2007 19:17:06 +0100

> Fix use of __exit functions from __init path.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
