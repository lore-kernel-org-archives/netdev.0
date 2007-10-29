From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: [2.6 patch] remove Documentation/networking/net-modules.txt
Date: Mon, 29 Oct 2007 17:18:14 +0200
Message-ID: <20071029151813.GA22960@ee.oulu.fi>
References: <20071024162503.GT30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:34819 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503AbXJ2PTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 11:19:14 -0400
Content-Disposition: inline
In-Reply-To: <20071024162503.GT30533@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 24, 2007 at 06:25:03PM +0200, Adrian Bunk wrote:
> According to git, the only one who touched this file during the last
> 5 years was me when removing drivers...

That's not the only obsolete thing there:
>  ncsa-telnet
>  	- notes on how NCSA telnet (DOS) breaks with MTU discovery enabled.
And probably others too. Then again, the information there isn't wrong, it's
just totally useless these days :P

-- 
Pekka Pietikainen
