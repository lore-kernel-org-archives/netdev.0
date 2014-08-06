From: Hyong-Youb Kim <hyong-youb.kim@myricom.com>
Subject: Re: [PATCH] myri10ge: check for pci_map_page errors
Date: Wed, 6 Aug 2014 22:37:48 +0900
Message-ID: <53E22FAC.7040502@myricom.com>
References: <20140806132516.GA3222@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hyong-Youb Kim <hykim@myri.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0188.outbound.protection.outlook.com ([207.46.163.188]:33720
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750945AbaHFNiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 09:38:20 -0400
In-Reply-To: <20140806132516.GA3222@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 8/6/2014 10:25 PM, Stanislaw Gruszka wrote:
> On IOMMU systems DMA mapping can fail, we need to check for that
> possibility.
>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Acked-by: Hyong-Youb Kim <hykim@myri.com>

Thanks for the patch.
