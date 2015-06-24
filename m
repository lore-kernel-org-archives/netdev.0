From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: add support for switchdev VLAN objects
Date: Wed, 24 Jun 2015 01:39:31 -0700 (PDT)
Message-ID: <20150624.013931.1018813927599601720.davem@davemloft.net>
References: <1435079929-23018-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, linux@roeck-us.net,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbFXI1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 04:27:40 -0400
In-Reply-To: <1435079929-23018-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 23 Jun 2015 13:18:49 -0400

> This patch adds the glue between DSA and switchdev operations to add,
> delete and dump SWITCHDEV_OBJ_PORT_VLAN objects.
> 
> This is a first step to link the "bridge vlan" command with hardware
> entries for DSA compatible switch chips.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Please resubmit this alongside some actual users.

THanks.
