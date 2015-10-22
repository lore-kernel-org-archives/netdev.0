From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] xen-netback/core: packet hashing
Date: Thu, 22 Oct 2015 07:15:13 -0700 (PDT)
Message-ID: <20151022.071513.1802223326387772273.davem@davemloft.net>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54253 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757761AbbJVN6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 09:58:46 -0400
In-Reply-To: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 21 Oct 2015 11:36:17 +0100

> This series adds xen-netback support for hash negotiation with a frontend
> driver, and an implementation of toeplitz hashing as the initial negotiable
> algorithm.

I'd definitely like to see some XEN networking experts review this
before I apply it.
