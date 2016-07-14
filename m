From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -next] wan/fsl_ucc_hdlc: info leak in uhdlc_ioctl()
Date: Thu, 14 Jul 2016 14:17:28 +0300
Message-ID: <20160714111728.GG32301@mwanda>
References: <20160714103415.GE18175@mwanda>
 <57876EE0.10603@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhao Qiang <qiang.zhao@nxp.com>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46826 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbcGNLRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 07:17:42 -0400
Content-Disposition: inline
In-Reply-To: <57876EE0.10603@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good point.  Thanks.

regards,
dan carpenter
