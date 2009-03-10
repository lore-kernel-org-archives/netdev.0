From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] bnx2x: net-2.6 Bug Fixes
Date: Tue, 10 Mar 2009 05:08:36 -0700 (PDT)
Message-ID: <20090310.050836.12868611.davem@davemloft.net>
References: <1236595929.11030.11.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, achiang@hp.com, bjorn.helgaas@hp.com,
	vladz@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46799
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751732AbZCJMIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 08:08:51 -0400
In-Reply-To: <1236595929.11030.11.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 09 Mar 2009 12:52:09 +0200

> This patch series against net-2.6 contains critical bug fixes for the
> bnx2x.

All applied, thanks.

> The first two issues manifest themselves on IA64 with 64KB pages and
> were reported and tested by Bjorn Helgass <bjorn.helgass@hp.com>. Those
> two do not exist in net-next. Please let me know if you want me to send
> a patch against net-next with those fixes (or if you can apply it to
> net-next as well).

This gets taken care of this transparently when I pull net-2.6 into
net-next-2.6, which I have to do occaisionally anyways.

