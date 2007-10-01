From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: DLPAR memory add fix
Date: Mon, 01 Oct 2007 10:44:41 -0400
Message-ID: <470107D9.2040301@garzik.org>
References: <200710011633.18305.ossthema@de.ibm.com>
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
Received: from srv5.dvmed.net ([207.36.208.214]:34826 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbXJAOon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 10:44:43 -0400
In-Reply-To: <200710011633.18305.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> Due to stability issues in high load situations the HW queue handling
> has to be changed. The HW queues are now stopped and restarted again instead
> of destroying and allocating new HW queues. 
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

May I presume this is for 2.6.23?

	Jeff



