From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Mon, 13 Nov 2006 07:43:50 +0000
Message-ID: <200611130743.50756@strip-the-willow>
References: <200611101609.21333@strip-the-willow> <20061110093715.0aadd791@freekitty> <20061110.143846.93212026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:41380 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1754224AbWKMHoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 02:44:18 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061110.143846.93212026.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  > This code is does too much inlining (like existing network code).
|  > Should it be made configurable?
|  
|  It doesn't get built at all if you check his patches :-)
See previous posting.
