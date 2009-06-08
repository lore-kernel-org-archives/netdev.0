From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] tun: Fix copy/paste error in tun_get_user
Date: Mon, 08 Jun 2009 00:29:08 -0700 (PDT)
Message-ID: <20090608.002908.251137049.davem@davemloft.net>
References: <1244230546.1526.78.camel@w-sridhar.beaverton.ibm.com>
	<20090606210833.GB28614@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38349
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752809AbZFHH3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:29:06 -0400
In-Reply-To: <20090606210833.GB28614@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 7 Jun 2009 00:08:33 +0300

> On Fri, Jun 05, 2009 at 12:35:46PM -0700, Sridhar Samudrala wrote:
>> Use the right structure while incrementing the offset in tun_get_user.
>> 
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
