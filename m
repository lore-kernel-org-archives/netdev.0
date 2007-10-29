From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: add kexec support
Date: Mon, 29 Oct 2007 05:47:35 -0400
Message-ID: <4725AC37.2050903@garzik.org>
References: <200710261437.29117.ossthema@de.ibm.com>
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
Received: from srv5.dvmed.net ([207.36.208.214]:43867 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238AbXJ2Jrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 05:47:40 -0400
In-Reply-To: <200710261437.29117.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> eHEA resources that are allocated via H_CALLs have a unique identifier each.
> These identifiers are necessary to free the resources. A reboot notifier
> is used to free all eHEA resources before the indentifiers get lost, i.e
> before kexec starts a new kernel.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

applied to #upstream-fixes


