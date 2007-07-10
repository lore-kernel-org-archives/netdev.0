From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [2.6 patch] the scheduled sk98lin removal
Date: Tue, 10 Jul 2007 09:49:54 -0700
Message-ID: <20070710094954.788aa357@freepuppy.rosehill.hemminger.net>
References: <20070709145916.GE3492@stusta.de>
	<4693B773.2080205@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42207 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754381AbXGJQuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 12:50:14 -0400
In-Reply-To: <4693B773.2080205@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jul 2007 12:44:35 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Adrian Bunk wrote:
> > This patch contains the scheduled removal of the sk98lin driver.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Stephen -- ACK?

Yes.  Existing driver is dead, if there are any ancient boards that don't
work with skge, I haven't heard any complaints in at least a year.
As a fallback users, can always go with vendor driver.
