From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: kbuild dependency fix
Date: Mon, 24 Jan 2011 23:37:05 -0800 (PST)
Message-ID: <20110124.233705.260069637.davem@davemloft.net>
References: <4d3c86b8.114ddf0a.7de4.ffffe043@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kernel@fomichev.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52249
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751724Ab1AYHga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 02:36:30 -0500
In-Reply-To: <4d3c86b8.114ddf0a.7de4.ffffe043@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislav Fomichev <kernel@fomichev.me>
Date: Sun, 23 Jan 2011 22:51:16 +0300

> Hello all,
> I'm not sure if it's the right place to send this patch, but I didn't find a better one.
> 
> Here is a small fix for netconsole dependency (upon config fs) that I unintentionally found.
> 
> Hope you'll find it useful.
> 
> This patch is for 2.6.38-rc2.

Please show the configuration and build error messages from when the
build fails, otherwise we have to guess what causes the dependency.

Secondly, please read "Documentation/SubmittingPatches" to learn how
to properly submit a patch, in particular your submission is missing
a proper "Signed-off-by" line.

Thirdly, you might want to CC: whoever created this dependency or
has been playing out in this area lately so that they can review
you patch and see the mistake they made and thus provide feedback.

Thanks.
