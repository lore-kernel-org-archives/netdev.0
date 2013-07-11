From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix tunneling CSUM calculation
Date: Thu, 11 Jul 2013 11:48:50 -0700 (PDT)
Message-ID: <20130711.114850.401538105961344406.davem@davemloft.net>
References: <1373546901-26741-1-git-send-email-dmitry@broadcom.com>
	<1373550852.4600.39.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com, pshelar@nicira.com,
	xiyou.wangcong@gmail.com, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533Ab3GKSsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 14:48:51 -0400
In-Reply-To: <1373550852.4600.39.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Jul 2013 06:54:12 -0700

> On Thu, 2013-07-11 at 15:48 +0300, Dmitry Kravkov wrote:
>> Since commit c957d09ffda417f6c8e3d1f10e2b05228607d6d7
>> "bnx2x: Remove sparse and coccinelle warnings"
>> driver provided wrong partial csum for HW in tunneing
>> scenarios.
>> 
>> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Alexander Duyck <alexander.h.duyck@intel.com>
>> CC: Pravin Shelar <pshelar@nicira.com>
>> CC: Cong Wang <xiyou.wangcong@gmail.com>
>> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
 ...
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
