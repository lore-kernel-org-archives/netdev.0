From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] [IrDA] Fix IrDA build failure
Date: Mon, 16 Jul 2007 16:17:08 +0400
Message-ID: <20070716121708.GA24483@2ka.mipt.ru>
References: <20070716111715.GB22757@mail.solidboot.com> <20070716115624.GA4492@2ka.mipt.ru> <20070716120744.GD3653@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Samuel Ortiz <samuel.ortiz@solidboot.com>, davem@davemloft.net,
	eric.y.miao@gmail.com, sam@ravnborg.org, netdev@vger.kernel.org,
	irda-users@lists.sourceforge.net, stable@kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43647 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758917AbXGPMUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 08:20:53 -0400
Content-Disposition: inline
In-Reply-To: <20070716120744.GD3653@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 02:07:44PM +0200, Adrian Bunk (bunk@stusta.de) wrote:
> > What about having all of them __devinit/__devexit?
> 
> That would be completely wrong.

Hi Adrian.

Then why should irda have __init/__exit at first point - replacing that
with appropriate 'dev' prefix I suggested.

-- 
	Evgeniy Polyakov
