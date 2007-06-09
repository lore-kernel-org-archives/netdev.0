From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/4] NetXen: Fix compile failure seen on PPC architecture
Date: Sat, 09 Jun 2007 18:26:25 -0400
Message-ID: <466B2911.50006@garzik.org>
References: <200706071136.l57Baauh007637@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35165 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755365AbXFIW01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:26:27 -0400
In-Reply-To: <200706071136.l57Baauh007637@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral wrote:
> NetXen: Add NETXEN prefixes to macros to clean them up.
> This is a cleanup patch which adds NETXEN prefix to some stand 
> alone macro names.
> These posed compile errors when NetXen driver was backported to 2.6.9
> on PPC architecture as macros like USER_START are defined in file
> arch/ppc64/mm/hash_utils.c
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
> Acked-off by: Mithlesh Thukral <mithlesh@netxen.com>

applied


