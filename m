From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Sun, 28 Sep 2014 14:11:37 +0200
Message-ID: <1411906297.2400343.172598909.66223582@webmail.messagingengine.com>
References: <52EFFE20.5080500@candelatech.com>
 <20140203220323.GB17999@order.stressinduktion.org>
 <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com>
 <20140208172310.GF16198@order.stressinduktion.org>
 <loom.20140926T001736-777@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Hongmei Li <duckcncn@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55630 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753940AbaI1MLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 08:11:38 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id D699920746
	for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 08:11:37 -0400 (EDT)
In-Reply-To: <loom.20140926T001736-777@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hongmei,

On Fri, Sep 26, 2014, at 00:24, Hongmei Li wrote:
> Hi Hannes and Ben,
> 
> I encounter the same kernel panic.
> Do you guys have any progress on this issue?

Unfortunately not, not looked into it for a long time.

Can you send me a fast reproducer script? I have better machines to
reproduce this issue nowadays.

Thanks,
Hannes
