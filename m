From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH 2/2] Do not set shared_ports when nreq > MAX_MSIX
Date: Thu, 8 Oct 2015 14:49:36 +0300
Message-ID: <56165850.3050703@mellanox.com>
References: <1444166829-17638-2-git-send-email-clsoto@linux.vnet.ibm.com>
 <CAJ3xEMjYtmSj3kBo24w+4Y3Nh60C9J=NHb_=YQw1QASJ1i_i1g@mail.gmail.com>
 <5614411E.1070105@linux.vnet.ibm.com>
 <20151008.045454.1028964260721714737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <gerlitz.or@gmail.com>, <matanb@mellanox.com>,
	<netdev@vger.kernel.org>, <brking@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>, <clsoto@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0085.outbound.protection.outlook.com ([157.55.234.85]:43447
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756809AbbJHLt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 07:49:58 -0400
In-Reply-To: <20151008.045454.1028964260721714737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/8/2015 2:54 PM, David Miller wrote:
> Also please fix you subject to have a proper "mlx4: " subsystem prefix. 

Carol, I have the patch and will submit it with other fixes that we have.

Or.
