From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 0/6] bnx2x: patch series
Date: Mon, 18 Oct 2010 10:59:15 +0200
Message-ID: <1287392355.11597.16.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, vladz@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1683 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754524Ab0JRJMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 05:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is the respin of previous series with following changes:
	1. removed patch with gso_size
	2. removed FUNC_FLG_RSS flag and appropriate "if"s (as suggested by Joe Perches)
	3. update version

Please, consider applying to net-next

Thanks
Dmitry




