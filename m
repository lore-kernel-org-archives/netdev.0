From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Ethernet driver general problem ....
Date: Thu, 9 Jun 2005 23:12:26 +0200
Message-ID: <20050609211226.GA7387@electric-eye.fr.zoreil.com>
References: <20050609205348.GT4661@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Content-Disposition: inline
In-Reply-To: <20050609205348.GT4661@mea-ext.zmailer.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matti Aarnio <matti.aarnio@zmailer.org> :
[...]
> Comments ?  Suggestions ?

See the use of ethtool_ops.set_ringparam() below drivers/net.

--
Ueimor
