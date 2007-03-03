From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ehea: dynamic add / remove port
Date: Fri, 02 Mar 2007 20:06:17 -0500
Message-ID: <45E8CA09.9030104@garzik.org>
References: <200702281834.02990.ossthema@de.ibm.com>
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
Received: from srv5.dvmed.net ([207.36.208.214]:55443 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992840AbXCCBGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:06:24 -0500
In-Reply-To: <200702281834.02990.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> This patch introduces functionality to dynamically add / remove
> ehea ports via an userspace DLPAR tool. It creates a subnode for
> each logical port in the sysfs. 
> 
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

applied 1-2 to #upstream (2.6.22)

your patches added much trailing whitespace.  please fix.


