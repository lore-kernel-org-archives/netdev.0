From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.22-rc4] ehea: Fixed possible kernel panic on VLAN
 packet recv
Date: Sat, 09 Jun 2007 18:26:32 -0400
Message-ID: <466B2918.9070400@garzik.org>
References: <200706062053.16986.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <ossthema@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35174 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755996AbXFIW0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:26:36 -0400
In-Reply-To: <200706062053.16986.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Klein wrote:
> This patch fixes a possible kernel panic due to not checking the vlan group
> when processing received VLAN packets and a malfunction in VLAN/hypervisor
> registration.
> 
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>

applied


