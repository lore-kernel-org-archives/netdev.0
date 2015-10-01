From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [patch net-next v2 5/6] switchdev: bring back switchdev_obj and
 use it as a generic object param
Date: Thu, 1 Oct 2015 12:40:17 -0400
Message-ID: <20151001164016.GE11616@ketchup.mtl.sfl>
References: <1443690226-29833-1-git-send-email-jiri@resnulli.us>
 <1443690226-29833-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:60095
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754176AbbJAQkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 12:40:20 -0400
Content-Disposition: inline
In-Reply-To: <1443690226-29833-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Thursday 01 (40) 11:03 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Replace "void *obj" with a generic structure. Introduce couple of
> helpers along that.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
