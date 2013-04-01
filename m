From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Mon, 1 Apr 2013 15:13:57 +0100
Message-ID: <20130401141357.GA10600@sirena.org.uk>
References: <A5ACC15C-361D-48E6-BFFF-9AA3966C2A68@freescale.com>
 <20130322.103302.1277256650283142022.davem@davemloft.net>
 <FE78128C-01DB-4831-ACBE-BA3E3A428BFC@gmail.com>
 <20130322.111759.2108472348146991505.davem@davemloft.net>
 <9AEAD974-4549-475A-AE15-C92523CD2466@gmail.com>
 <20130322220840.GA6647@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Theodore Ts'o <tytso@mit.edu>,
	Ben Collins <benmcollins13@gmail.com>,
	David Miller <davem@davemloft.net>, afleming@freescale.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:38181 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756736Ab3DAOeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 10:34:02 -0400
Content-Disposition: inline
In-Reply-To: <20130322220840.GA6647@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 22, 2013 at 06:08:40PM -0400, Theodore Ts'o wrote:

[Insisting on upstream drivers]
> I've been waiting for this to start happening in the consumer
> electronics/embedded world, but it's been slow coming,
> unfortunately....

For CE at least it's not really relevant as nobody's got much intention
of upgrading the kernel on a shipping device, other than code review
there's not much benefit to the system integrator and that's generally
tilting at windmills a bit.
