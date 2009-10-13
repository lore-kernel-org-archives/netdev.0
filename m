From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] netxen: fix pci bar mapping
Date: Tue, 13 Oct 2009 00:26:10 -0700 (PDT)
Message-ID: <20091013.002610.150908464.davem@davemloft.net>
References: <1255329573-17701-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933659AbZJMH0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:26:14 -0400
In-Reply-To: <1255329573-17701-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 11 Oct 2009 23:39:33 -0700

> Use resource_size_t for PCI resource remapping instead
> of unsigned long. Physical addresses can exceed range of
> long data type (e.g with PAE).
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
