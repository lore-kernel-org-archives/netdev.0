From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 03/25] bonding: convert packets_per_slave to use the new option API
Date: Wed, 22 Jan 2014 08:25:28 +0100
Message-ID: <20140122072528.GD28225@order.stressinduktion.org>
References: <1390316114-17815-1-git-send-email-nikolay@redhat.com> <1390316114-17815-4-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57170 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601AbaAVHZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:25:30 -0500
Content-Disposition: inline
In-Reply-To: <1390316114-17815-4-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay!

On Tue, Jan 21, 2014 at 03:54:52PM +0100, Nikolay Aleksandrov wrote:
> This patch adds the necessary changes so packets_per_slave would use the
> new bonding option API.

Just want to warn you that because of the reciproal_divide merge in net-next
there will be some conflicts with this patch in net-next.

I actually looked to rebase Daniel and my series on your patchset, but now
David pulled ours first.

Greetings,

  Hannes
