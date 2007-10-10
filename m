From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6.24] cxgb3 sparse warning fixes
Date: Tue, 09 Oct 2007 20:39:47 -0400
Message-ID: <470C1F53.2020409@pobox.com>
References: <20071008162229.65237a88@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39102 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754582AbXJJAju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:39:50 -0400
In-Reply-To: <20071008162229.65237a88@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix warnings from sparse related to shadowed variables and routines
> that should be declared static.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied


