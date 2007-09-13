From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2][RESEND] ehea: propagate physical port state
Date: Thu, 13 Sep 2007 00:14:01 -0400
Message-ID: <46E8B909.2050201@garzik.org>
References: <200709071230.18395.ossthema@de.ibm.com>
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
Received: from srv5.dvmed.net ([207.36.208.214]:40002 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875AbXIMEOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:14:09 -0400
In-Reply-To: <200709071230.18395.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> Introduces a module parameter to decide whether the physical
> port link state is propagated to the network stack or not.
> It makes sense not to take the physical port state into account
> on machines with more logical partitions that communicate
> with each other. This is always possible no matter what the physical
> port state is. Thus eHEA can be considered as a switch there.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

applied 1-2


