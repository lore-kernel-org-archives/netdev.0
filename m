From: James Morris <jmorris@namei.org>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Thu, 12 Jul 2007 22:26:00 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707122225470.13816@d.namei>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
 <20070712.135254.112289065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jens.axboe@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:58381 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759619AbXGMC0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 22:26:02 -0400
In-Reply-To: <20070712.135254.112289065.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007, David Miller wrote:

> From: James Morris <jmorris@namei.org>
> Date: Thu, 12 Jul 2007 16:12:25 -0400 (EDT)
> 
> > I'm seeing TCP connection stalls with current git, and a bisect found the 
> > following as a possible cause:
> 
> To add to this James is seeing this with distcc I believe.

Correct.

-- 
James Morris
<jmorris@namei.org>
