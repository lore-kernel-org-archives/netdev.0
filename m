From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] net: freescale: Fix module autoload for OF platform
 driver
Date: Fri, 18 Sep 2015 21:23:46 +0200
Message-ID: <20150918192346.GD1802@localhost.localdomain>
References: <20150918155527.GA24827@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Luis de Bethencourt <luis@debethencourt.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37163 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbbIRTXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 15:23:51 -0400
Content-Disposition: inline
In-Reply-To: <20150918155527.GA24827@goodgumbo.baconseed.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 05:55:27PM +0200, Luis de Bethencourt wrote:
> This platform driver has a OF device ID table but the OF module
> alias information is not created so module autoloading won't work.
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>

Nit: The subject line should have been:

	net: gianfar_ptp: ...

Acked-by: Richard Cochran <richardcochran@gmail.com>
