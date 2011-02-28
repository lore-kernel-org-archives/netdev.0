From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6 4/4] bridge: implement slave management
 operations
Date: Mon, 28 Feb 2011 14:45:16 -0800
Message-ID: <20110228144516.0174a9c8@nehalam>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
	<20110211152346.GD2763@psychotron.brq.redhat.com>
	<20110228141729.09c3b770@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net, fubar@us.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56644 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab1B1WpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 17:45:18 -0500
In-Reply-To: <20110228141729.09c3b770@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Feb 2011 14:17:29 -0800
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> On Fri, 11 Feb 2011 16:23:47 +0100
> Jiri Pirko <jpirko@redhat.com> wrote:
> 
> > 
> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 

Never mind, this is good. I was confusing slave with bridge initialization
and netdevice ops with ethtool ops.

Ethtool ops seems to be growing like weeds lately...



-- 
