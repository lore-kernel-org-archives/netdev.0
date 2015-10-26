From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Implement FDB operations
Date: Mon, 26 Oct 2015 16:51:05 -0400
Message-ID: <20151026205102.GA17064@ketchup.mtl.sfl>
References: <1445625487-16313-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	andrew@lunn.ch, linux@roeck-us.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34454 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbbJZUvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 16:51:14 -0400
Content-Disposition: inline
In-Reply-To: <1445625487-16313-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Friday 23 (43) 11:38 AM, Florian Fainelli wrote:
> Add support for the FDB add, delete, and dump operations. The add and
> delete operations are implemented using directed ARL operations using
> the specified MAC address and consist in a read operation, write and
> readback operation.
> 
> The dump operation consists in using the ARL search and software
> filtering entries which are not for the desired port.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
