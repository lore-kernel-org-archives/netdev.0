From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sis900: use pci_dev->revision
Date: Mon, 28 Feb 2011 12:29:46 -0800 (PST)
Message-ID: <20110228.122946.246532855.davem@davemloft.net>
References: <201102222329.02049.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, venza@brownhat.org
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43204
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752955Ab1B1U3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:29:09 -0500
In-Reply-To: <201102222329.02049.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Tue, 22 Feb 2011 23:29:01 +0300

> This driver uses PCI_CLASS_REVISION instead of PCI_REVISION_ID, so it wasn't
> converted by commit 44c10138fd4bbc4b6d6bff0873c24902f2a9da65 (PCI: Change all
> drivers to use pci_device->revision).
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied, thanks.
