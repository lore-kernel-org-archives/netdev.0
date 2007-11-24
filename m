From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2][2.6.24] ehea: Improve tx packets counting
Date: Fri, 23 Nov 2007 22:09:58 -0500
Message-ID: <47479606.10004@garzik.org>
References: <200711211737.58789.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44343 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890AbXKXDKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:10:02 -0500
In-Reply-To: <200711211737.58789.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Klein wrote:
> Using own tx_packets counter instead of firmware counters.
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> 
> ---
>  drivers/net/ehea/ehea.h      |    2 +-
>  drivers/net/ehea/ehea_main.c |    9 +++++++--
>  2 files changed, 8 insertions(+), 3 deletions(-)

applies 1-2 to #upstream-fixes


