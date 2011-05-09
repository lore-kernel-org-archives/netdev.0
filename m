From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] tulip: Convert uses of KERN_DEBUG
Date: Mon, 09 May 2011 12:52:01 -0700 (PDT)
Message-ID: <20110509.125201.15236407.davem@davemloft.net>
References: <cover.1304970062.git.joe@perches.com>
	<7686b8ddd70df6d46eac56b40bedc4b4d267af3f.1304970062.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60569
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754574Ab1EITwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:52:33 -0400
In-Reply-To: <7686b8ddd70df6d46eac56b40bedc4b4d267af3f.1304970062.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon,  9 May 2011 12:45:22 -0700

> Convert logging messages to more current styles.
> 
> Added -DDEBUG to Makefile to maintain current message logging.
> This could be converted to a specific CONFIG_TULIP_DEBUG option.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
