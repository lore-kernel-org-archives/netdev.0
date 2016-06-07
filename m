From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 3/5] net: dsa: Add initialization helper for CPU port ethtool_ops
Date: Tue, 07 Jun 2016 09:05:23 -0400
Message-ID: <871t499mjw.fsf@ketchup.mtl.sfl>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com> <1465254895-11152-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemlof.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40941 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102AbcFGNF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 09:05:26 -0400
In-Reply-To: <1465254895-11152-4-git-send-email-f.fainelli@gmail.com>
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
