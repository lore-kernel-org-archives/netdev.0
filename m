From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 4/6] ehea: header files
Date: Sat, 12 Aug 2006 08:07:28 +1000
Message-ID: <20060811220728.GI479@krispykreme>
References: <44D99F56.7010201@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:62852 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932448AbWHKWK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 18:10:29 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44D99F56.7010201@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea.h	1969-12-31 

> +extern void exit(int);

Should be able to remove that prototype :) 

Anton
