From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/6] sky2: better power state management
Date: Tue, 26 Dec 2006 16:37:56 -0500
Message-ID: <45919634.4010003@pobox.com>
References: <20061220210632.183204605@osdl.org> <20061220210923.245868668@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41520 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932804AbWLZViA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:38:00 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061220210923.245868668@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Improve power management and error handling by using pci_set_power_state(),
> instead of driver doing PCI PM register changes in the driver.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

applied


