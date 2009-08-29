From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: switch to seq_file
Date: Sat, 29 Aug 2009 00:21:12 -0700 (PDT)
Message-ID: <20090829.002112.160212045.davem@davemloft.net>
References: <20090828195721.GD15123@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751814AbZH2HU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:20:58 -0400
In-Reply-To: <20090828195721.GD15123@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 28 Aug 2009 23:57:21 +0400

> create_proc_read_entry() is going to be removed soon.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6, thanks.
