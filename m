From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Trivial fix to message in tcp_v4_inbound_md5_hash
Date: Sun, 17 Dec 2006 17:13:22 -0800 (PST)
Message-ID: <20061217.171322.70706696.davem@davemloft.net>
References: <42087.81.105.127.245.1166378655.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39566
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750753AbWLRBNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 20:13:22 -0500
To: leigh@solinno.co.uk
In-Reply-To: <42087.81.105.127.245.1166378655.squirrel@www.solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Leigh Brown" <leigh@solinno.co.uk>
Date: Sun, 17 Dec 2006 18:04:15 -0000 (GMT)

> The message logged in tcp_v4_inbound_md5_hash when the hash was expected
> but not found was reversed.
> 
> Signed-off-by: Leigh Brown <leigh@solinno.co.uk>

Also applied, thanks.
