From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.19-rc3 1/2] ehea: kzalloc GFP_ATOMIC fix
Date: Tue, 31 Oct 2006 20:20:06 -0500
Message-ID: <4547F646.2080000@garzik.org>
References: <200610251311.43009.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:28627 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423918AbWKABUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 20:20:19 -0500
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <200610251311.43009.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> This patch fixes kzalloc parameters (GFP_ATOMIC instead of GFP_KERNEL)
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

applied to #upstream-fixes

In the future, please include a description of -why- patches like this 
are needed (I got the info from your replies in this case)


