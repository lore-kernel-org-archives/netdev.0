From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] pxa168_eth: fix a mdiobus leak
Date: Mon, 30 Aug 2010 10:47:30 +0200
Message-ID: <20100830084730.GM9832@bicker>
References: <20100830072138.GA8797@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ssanap@marvell.com, netdev@vger.kernel.org
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57888 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662Ab0H3IsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 04:48:01 -0400
Received: by eyg5 with SMTP id 5so3024609eyg.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 01:48:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100830072138.GA8797@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 07:21:38AM +0000, Denis Kirjanov wrote:
> mdiobus resources must be released on exit
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Acked-by: Dan Carpenter <error27@gmail.com>

