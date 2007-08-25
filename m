From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] ehea: fix interface to DLPAR tools
Date: Sat, 25 Aug 2007 00:41:17 -0400
Message-ID: <46CFB2ED.3010901@garzik.org>
References: <200708221620.59078.ossthema@de.ibm.com>
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
Received: from srv5.dvmed.net ([207.36.208.214]:42179 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752433AbXHYElT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:41:19 -0400
In-Reply-To: <200708221620.59078.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann wrote:
> Userspace DLPAR tool expects decimal numbers to be written to
> and read from sysfs entries.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

applied 1-3


