From: olof@lixom.net (Olof Johansson)
Subject: Re: [RESEND] [PATCH v2] [4/5] pasemi_mac: phy support
Date: Sat, 28 Apr 2007 15:09:47 -0500
Message-ID: <20070428200947.GC2442@lixom.net>
References: <20070428054952.GA22074@lixom.net> <20070428055140.GE22074@lixom.net> <463366FE.60201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:56456 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbXD1UJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:09:10 -0400
Content-Disposition: inline
In-Reply-To: <463366FE.60201@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2007 at 11:23:42AM -0400, Jeff Garzik wrote:

> msg_enable should be initialized in a standard fashion, from your debug 
> module parameter.  grep for 'msg_enable' in other drivers.

Ah, good point. Done, and broken out as a separate patch.


Thanks,

-Olof
