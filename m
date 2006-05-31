From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Wed, 31 May 2006 02:00:09 -0600
Message-ID: <20060531020009.A1868@openss7.org>
References: <20060530235525.A30563@openss7.org> <20060531.001027.60486156.davem@davemloft.net> <20060531014540.A1319@openss7.org> <20060531.004953.91760903.davem@davemloft.net>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: draghuram@rocketmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:17388 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S964829AbWEaIAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 04:00:11 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060531.004953.91760903.davem@davemloft.net>; from davem@davemloft.net on Wed, May 31, 2006 at 12:49:53AM -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On Wed, 31 May 2006, David Miller wrote:
> 
> For sure and there are plans afoot to move over to
> dynamic table sizing and the Jenkins hash function.

Yes, that could be far more efficient.

