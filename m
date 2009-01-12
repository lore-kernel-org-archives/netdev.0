From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: Network device with variable hard header len
Date: Mon, 12 Jan 2009 11:48:19 +0000
Message-ID: <20090112114817.GB32299@sirena.org.uk>
References: <20090110112812.GA8393@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:1212 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbZALMHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 07:07:21 -0500
Content-Disposition: inline
In-Reply-To: <20090110112812.GA8393@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 10, 2009 at 02:28:12PM +0300, Dmitry Eremin-Solenikov wrote:

> Sorry if this a dumb question. Currently I'm programming a driver for
> the devices with variable network header len. From the Linux net stack
> perspective what should I do: set netdev->hard_header_len to maximum
> possible header and use less space that specified there or set
> netdev->needed_headroom to that value?

> If that metters, I'll be implementing my own set of header_ops in any
> case.

This is probably better asked on netdev (CCed).
