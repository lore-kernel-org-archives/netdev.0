From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: avoid errors from double-installing manpages
Date: Sun, 11 Nov 2012 16:23:09 -0800
Message-ID: <20121111162309.7bc88e50@nehalam.linuxnetplumber.net>
References: <20121109154241.GA29156@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51119 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751245Ab2KLAYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2012 19:24:11 -0500
In-Reply-To: <20121109154241.GA29156@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Nov 2012 16:42:41 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> Three manpages in man8 are listed twice in MAN8PAGES (both directly and
> in TARGETS) which causes the install command to spit our a couple of
> warnings as below and exiting with non-zero exit code....
> 

Applied
