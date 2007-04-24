From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ehea: fix for dlpar and sysfs entries
Date: Tue, 24 Apr 2007 14:01:41 -0400
Message-ID: <462E4605.7070706@garzik.org>
References: <200704051122.28428.ossthema@de.ibm.com>
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
Received: from srv5.dvmed.net ([207.36.208.214]:40317 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422955AbXDXSBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 14:01:48 -0400
In-Reply-To: <200704051122.28428.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> This patch includes:
> - dlpar fix: 
> 	certain resources may only be allocated when first
> 	logical port is available, and must be removed when
> 	last logical port has been removed
> 
> - sysfs entries:
> 	create symbolic link from each logical port to ehea driver
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

What Arnd said... this should be two patches


