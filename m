From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] allow pkg-config to be customized
Date: Sun, 11 Nov 2012 16:21:52 -0800
Message-ID: <20121111162152.27df1eb6@nehalam.linuxnetplumber.net>
References: <1352392877-22300-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51074 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab2KLAWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2012 19:22:54 -0500
In-Reply-To: <1352392877-22300-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Nov 2012 11:41:17 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> Rather than hard coding `pkg-config`, use ${PKG_CONFIG} so people can
> override it to their specific version (like when cross-compiling).
> 
> This is the same way the upstream pkg-config code works.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied, thanks.
