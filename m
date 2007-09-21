From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] sb1250-mac: Driver model & phylib update
Date: Fri, 21 Sep 2007 12:44:09 -0700
Message-ID: <20070921124409.7f3d122b.akpm@linux-foundation.org>
References: <Pine.LNX.4.64N.0709191811040.24627@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57013 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761406AbXIUTpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 15:45:14 -0400
In-Reply-To: <Pine.LNX.4.64N.0709191811040.24627@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Sep 2007 12:52:10 +0100 (BST)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

>  A driver model and phylib update.

akpm:/usr/src/25> diffstat patches/git-net.patch | tail -n 1
 1013 files changed, 187667 insertions(+), 23587 deletions(-)

Sorry, but raising networking patches against Linus's crufty
old mainline tree just isn't viable at present.
