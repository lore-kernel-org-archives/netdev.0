From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 08/15] igb: add function to handle mailbox
 lock
Date: Tue, 06 Oct 2009 15:21:21 -0700 (PDT)
Message-ID: <20091006.152121.08315815.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163345.32487.58098.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933725AbZJFWV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:21:26 -0400
In-Reply-To: <20091005163345.32487.58098.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:33:46 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Both the read and write mailbox functions need to acquire the mailbox lock.
> Since that is the case we might as well combine both of the procedures into
> one function so it is easier to maintain.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
