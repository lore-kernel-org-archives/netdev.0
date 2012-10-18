From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/6] drivers: net: ethernet: cpsw: add multicast
 address to ALE table
Date: Thu, 18 Oct 2012 04:49:28 +0200
Message-ID: <20121018024928.GC2867@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-4-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43888 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab2JRCti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 22:49:38 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so6825863wgb.1
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 19:49:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350427518-7230-4-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 04:15:15AM +0530, Mugunthan V N wrote:
> Adding multicast address to ALE table via netdev ops to subscribe, transmit
> or receive multicast frames to and from the network

Is this somehow related to the time stamping function? If so, how?

Thanks,
Richard
