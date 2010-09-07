From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/14] drivers/net: Removing undead ifdef CHELSIO_T1_1G
Date: Mon, 06 Sep 2010 18:39:42 -0700 (PDT)
Message-ID: <20100906.183942.52176647.davem@davemloft.net>
References: <cover.1283782698.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<fd089f3e72b01fc29faf8113606354f6c423f141.1283782701.git.qy03fugy@stud.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rolandd@cisco.com, adobriyan@gmail.com, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: qy03fugy@stud.informatik.uni-erlangen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755949Ab0IGBjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:39:25 -0400
In-Reply-To: <fd089f3e72b01fc29faf8113606354f6c423f141.1283782701.git.qy03fugy@stud.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Date: Mon, 6 Sep 2010 16:36:25 +0200

> The CHELSIO_T1_1G ifdef isn't necessary at this point, because it is
> checked in an outer ifdef level already and has no effect here.
> 
> Signed-off-by: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>

Applied.
