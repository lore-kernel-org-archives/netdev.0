From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] eHEA: net_poll support
Date: Tue, 24 Jul 2007 16:37:32 -0400
Message-ID: <46A6630C.9010502@garzik.org>
References: <200707231605.03459.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59019 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758233AbXGXUhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:37:36 -0400
In-Reply-To: <200707231605.03459.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> net_poll support for eHEA added
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> ---
> 
> 
>  drivers/net/ehea/ehea.h      |    2 +-
>  drivers/net/ehea/ehea_main.c |   22 +++++++++++++++++++++-
>  2 files changed, 22 insertions(+), 2 deletions(-)

applied


