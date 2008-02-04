From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: SCTP NAT module for netfilter
Date: Mon, 04 Feb 2008 10:40:57 -0500
Message-ID: <47A73209.5080604@hp.com>
References: <1C6541574A2FC447B53A6B4522B678AFF057C8@moe.nextone.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel-owner@vger.kernel.org
To: Sohan Shetty <sshetty@nextpointnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:36584 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbYBDPlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 10:41:20 -0500
In-Reply-To: <1C6541574A2FC447B53A6B4522B678AFF057C8@moe.nextone.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sohan Shetty wrote:
> Is  anyone aware if there an  NAT module for netfilter being developed for SCTP protocol ?

I don't believe there is one yet.  You are always welcome to write it.

> 
> 
> I have searched the netfilter development tree source code and also mailing list and so far I have not found the NAT module for SCTP . There is SCTP conntrack module and packet match module. 
> 
> If anyone is aware and can point me to  some one who is already working on this or has evaluated this it would be of great help.
> 
> 
> SCTP is defined in [RFC 2960] Stewart, R., Xie, Q., Morneault, K., Sharp, C., Schwarzbauer, H., Taylor, T., Rytina, I., Kalla, M., Zhang, L. and V. Paxson, "Stream Control Transmission Protocol", RFC 2960, October 2000. 
> 

This has been updated.  See RFC 4960.

-vlad
