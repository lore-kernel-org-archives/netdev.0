From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/3] cxgb3 - Driver updates
Date: Wed, 30 May 2007 21:10:32 -0700
Message-ID: <465E4AB8.2000903@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8132 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759899AbXEaEKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 00:10:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a patch series for inclusion in netdev#upstream.

Here is a brief description:
- update page management in the SGE code,
- update FW to 4.1 and proceed to subsequent HW tuning,
- allow microcode update without a power cycle.

Cheers,
Divy
