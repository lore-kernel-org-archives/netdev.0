From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: [PATCH] tcp: simpler bic default
Date: Tue, 19 Sep 2006 23:43:05 +0200
Message-ID: <20060919214304.GB13543@outpost.ds9a.nl>
References: <20060918214104.3824a2e2@localhost.localdomain> <20060919.123352.124082859.davem@davemloft.net> <20060919134132.44d4da5d@localhost.localdomain> <20060919.142007.06541289.davem@davemloft.net> <20060919143209.1164d803@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:48780 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1752086AbWISVnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:43:06 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060919143209.1164d803@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2006 at 02:32:09PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

# CONFIG_TCP_CONG_ADVANCED is not set
# CONFIG_DEFAULT_BIC is not set
# CONFIG_DEFAULT_CUBIC is not set
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"

There is no "bic" in the kernel now - will this do the right thing?

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
