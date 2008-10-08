From: David Miller <davem@davemloft.net>
Subject: Re: netxen: add sub vendor/device ids.
Date: Wed, 08 Oct 2008 16:51:48 -0700 (PDT)
Message-ID: <20081008.165148.244973548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757007AbYJHXwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 19:52:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm not applying this.

The (general) rule is that we don't add new entries to the pci_ids.h
file any more, instead we simply put the constants directly into the
PCI ID tables of the drivers.
