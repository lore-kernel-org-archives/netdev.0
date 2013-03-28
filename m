From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 7/7] ip/xfrm: Improve error strings
Date: Thu, 28 Mar 2013 14:47:32 -0700
Message-ID: <20130328144732.011781c9@nehalam.linuxnetplumber.net>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
	<1364221399-1024-7-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:50527 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab3C1Vrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 17:47:45 -0400
Received: by mail-pd0-f177.google.com with SMTP id y14so4225644pdi.22
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 14:47:44 -0700 (PDT)
In-Reply-To: <1364221399-1024-7-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Mar 2013 10:23:19 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> Quotation marks are now used only to indicate literal text on the
> command line.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

All applied, although last one need a little whitespace fix up.

/usr/src/iproute2/.git/rebase-apply/patch:16: space before tab in indent.
 	fprintf(stderr, "MODE := transport | tunnel | beet | ro | in_trigger\n");
/usr/src/iproute2/.git/rebase-apply/patch:39: space before tab in indent.
 	fprintf(stderr, "MODE := transport | tunnel | beet | ro | in_trigger\n");
warning: 2 lines add whitespace errors.
