From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC v2 2/7] net: netfilter conntrack - add per-net functionality
 for DCCP protocol
Date: Mon, 16 Mar 2009 16:31:30 +0100
Message-ID: <49BE70D2.9060604@trash.net>
References: <20090311205706.141086138@gmail.com> <20090311210817.172204517@gmail.com> <49B8CDC7.5070105@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48428 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754276AbZCPPbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 11:31:34 -0400
In-Reply-To: <49B8CDC7.5070105@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Cyrill Gorcunov wrote:
>> Module specific data moved into per-net site and being allocated/freed
>> during net namespace creation/deletion.
>>
>> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
>> ---
>>   
> Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>

Applied, thanks.
