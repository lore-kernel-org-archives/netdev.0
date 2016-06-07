From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v3 4/6] net: dsa: Add initialization helper for CPU port ethtool_ops
Date: Tue, 07 Jun 2016 18:54:03 -0400
Message-ID: <878tyg7gqc.fsf@ketchup.mtl.sfl>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com> <1465333616-6351-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38039 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbcFGWyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:54:06 -0400
In-Reply-To: <1465333616-6351-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> Add a helper function: dsa_cpu_port_ethtool_init() which initializes a
> custom ethtool_ops structure with custom DSA ethtool operations for CPU
> ports. This is a preliminary change to move the initialization outside
> of net/dsa/slave.c.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
