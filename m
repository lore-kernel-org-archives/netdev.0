From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 3/3 v2] ssb: use pci_dev->subsystem_{vendor,device}
Date: Tue, 5 Jul 2011 15:34:19 -0400
Message-ID: <20110705193419.GE7540@tuxdriver.com>
References: <201107012234.42426.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mb@bu3sch.de, netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33694 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab1GETqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 15:46:51 -0400
Content-Disposition: inline
In-Reply-To: <201107012234.42426.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2011 at 10:34:42PM +0400, Sergei Shtylyov wrote:
> The SSB code reads PCI subsystem IDs from the PCI configuration registers while
> they are already stored by the PCI subsystem in the 'subsystem_{vendor|device}'
> fields of 'struct pci_dev'...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied.

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
