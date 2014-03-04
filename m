From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v4 0/3] 802.21 and MPLS headers and classification
Date: Tue, 04 Mar 2014 13:51:36 -0500 (EST)
Message-ID: <20140304.135136.953997395057467462.davem@davemloft.net>
References: <1393863792-18172-1-git-send-email-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de
To: sw@simonwunderlich.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbaCDSvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:51:39 -0500
In-Reply-To: <1393863792-18172-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>
Date: Mon,  3 Mar 2014 17:23:09 +0100

> this series contains a header file proposal for MPLS labels. These
> labels do not seem to be properly defined in the kernel so far. We are
> developing a wired/wireless 802.21/MPLS switch and need to check the
> MPLS labels to use the traffic control info for transmissions over
> 802.11 networks.
> 
> Changes to third version:
> 
>  * rename mpls_label_stack to mpls_label (thanks Neil)
>  * fix over-indendented closing brac (thanks Sergei)
>  * add Johannes' Ack

Series applied, thanks Simon.
