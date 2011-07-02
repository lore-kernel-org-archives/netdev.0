From: Phil Blundell <philb@gnu.org>
Subject: Re: [PATCH 03/12] econet: Reduce switch/case indent
Date: Sat, 02 Jul 2011 18:04:04 +0100
Message-ID: <1309626244.3651.0.camel@lenovo.internal.reciva.com>
References: <cover.1309549243.git.joe@perches.com>
	 <e2f659cf95b88abbdf35c7447d8a4d00d5c424dc.1309549244.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pbcl.net ([88.198.119.4]:35305 "EHLO hetzner.pbcl.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752443Ab1GBR2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jul 2011 13:28:21 -0400
In-Reply-To: <e2f659cf95b88abbdf35c7447d8a4d00d5c424dc.1309549244.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-07-01 at 12:43 -0700, Joe Perches wrote:
> Make the case labels the same indent as the switch.
> 
> Simplify a default case / return (unreached)
> Remove unnecessary break after return.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Phil Blundell <philb@gnu.org>

Thanks.

p.


