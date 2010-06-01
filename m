From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [patch 1/2] caif: remove unneeded variable from caif_net_open()
Date: Tue, 1 Jun 2010 09:19:06 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C10579169C3C247B@EXDCVYMBSTM005.EQ1STM.local>
References: <20100601070855.GD5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:60171 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411Ab0FAHTa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 03:19:30 -0400
In-Reply-To: <20100601070855.GD5483@bicker>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> We don't use the "ser" variable so I've removed it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Looks good thanks,
Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
