From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: remove bridge work
Date: Tue, 17 May 2016 12:42:36 -0400 (EDT)
Message-ID: <20160517.124236.184552515136376350.davem@davemloft.net>
References: <8737plig1v.fsf@ketchup.mtl.sfl>
	<20160516.134823.1909596879203571371.davem@davemloft.net>
	<87r3d01yok.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, f.fainelli@gmail.com,
	jiri@resnulli.us
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbcEQQmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 12:42:38 -0400
In-Reply-To: <87r3d01yok.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 17 May 2016 11:39:23 -0400

> Do we want to send this fix to -net as well?

net isn't open and is irrelevant right now, everything goes through the net-next
tree since we are in the merge window.
