From: "Merav Sicron" <meravs@broadcom.com>
Subject: Re: [net-next:master 232/235]
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:7053:6: sparse: symbol
 'bnx2x_init_searcher' was not declared. Should it be static?
Date: Thu, 8 Nov 2012 18:09:10 +0200
Message-ID: <1352390951.5555.5.camel@lb-tlvb-meravs.il.broadcom.com>
References: <20121108093805.GA1891@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>, netdev@vger.kernel.org
To: "Fengguang Wu" <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4144 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274Ab2KHM7G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 07:59:06 -0500
In-Reply-To: <20121108093805.GA1891@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 17:38 +0800, Fengguang Wu wrote:
> Hi Merav,
> 
> FYI, there are new sparse warnings show up in

Thanks. Before submitting I run sparse and it didn't catch these issues,
but apparently it didn't function well. I will submit a patch soon.
Merav
