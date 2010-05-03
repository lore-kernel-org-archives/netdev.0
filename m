From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v3] ixgbe: disable MSI-X by default on
 certain Cisco adapters
Date: Mon, 03 May 2010 15:18:55 -0700 (PDT)
Message-ID: <20100503.151855.38069977.davem@davemloft.net>
References: <20100428024521.28991.37874.stgit@localhost.localdomain>
	<w2u9929d2391005031516m6ae1bb3bpb9b4b9dc84bf4b1d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	nicholasx.d.nunley@intel.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754872Ab0ECWSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:18:49 -0400
In-Reply-To: <w2u9929d2391005031516m6ae1bb3bpb9b4b9dc84bf4b1d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 3 May 2010 15:16:07 -0700

> Dave please revert the following patch because it is being fixed
> without a software workaround:
> 
> commit d5ffd75a27fade39ba5df3b07290c5a2c297b9bd

Done.
