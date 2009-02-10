From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ppp: section fixes re netns
Date: Mon, 09 Feb 2009 18:05:23 -0800 (PST)
Message-ID: <20090209.180523.224752140.davem@davemloft.net>
References: <20090209222238.GA9692@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750696AbZBJCFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 21:05:30 -0500
In-Reply-To: <20090209222238.GA9692@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 10 Feb 2009 01:22:38 +0300

> PPP is modular code so no initdata on netns hooks.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
