From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] vxlan, bnx2x offload
Date: Mon, 29 Apr 2013 15:28:31 -0400 (EDT)
Message-ID: <20130429.152831.928050162837612262.davem@davemloft.net>
References: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org, pshelar@nicira.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759732Ab3D2T2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:28:34 -0400
In-Reply-To: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sun, 28 Apr 2013 21:16:00 +0300

> The series fixes GSO flags in vxlan xmit code and
> adds appropriate code for bnx2x driver to utilize
> fw support for UDP tunneling protocols offload.

Series applied, thanks.
