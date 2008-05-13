From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]: cpmac bugfixes and enhancements
Date: Tue, 13 May 2008 16:06:42 -0700
Message-ID: <20080513160642.a96dccbf.akpm@linux-foundation.org>
References: <200805041904.22726.matteo@openwrt.org>
	<20080505161634.6964d46b.akpm@linux-foundation.org>
	<200805140058.32890.matteo@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, ralf@linux-mips.org, nbd@openwrt.org,
	ejka@imfi.kspu.ru, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47086 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755644AbYEMXHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 19:07:15 -0400
In-Reply-To: <200805140058.32890.matteo@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008 00:58:32 +0200 Matteo Croce <matteo@openwrt.org> wrote:

> This one is cleaner:
> 
> 
> Signed-off-by: Matteo Croce <matteo@openwrt.org>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

It has no changelog.  We can neither effectively review it nor commit
it without one.

Each bugfix and each enhancement should be described, please.
