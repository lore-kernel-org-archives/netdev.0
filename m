From: divy <divy@chelsio.com>
Subject: [PATCH] cxgb3: Chelsio T3 1G/10G ethernet device driver
Date: Wed, 15 Nov 2006 16:11:36 -0800
Message-ID: <455BACB8.4010902@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:56858 "EHLO
	stargate.chelsio.com") by vger.kernel.org with ESMTP
	id S1162092AbWKPAMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 19:12:55 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch adds support for the latest Chelsio adapter, T3.

Since some files are bigger than the 40kB advertized in the submit
guidelines, a monolithic patch against 2.6.19-rc5 is posted at the
following URL: http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

Please advise on any other form you would like to see the code.

We wish this patch to be considered for inclusion in 2.6.20. This driver
will be required by the Chelsio T3 RDMA driver which will be posted for
review asap.

Cheers,
Divy
