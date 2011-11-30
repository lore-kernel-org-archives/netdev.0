From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC net-next] Include selection of congestion control algorithm
 in that which is inherited across an accept() call
Date: Wed, 30 Nov 2011 09:21:48 -0800
Message-ID: <4ED6662C.2090900@hp.com>
References: <20111130003112.C04FE29005FE@tardy> <1322630461.2596.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <raj@tardy.cup.hp.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:7097 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758010Ab1K3RVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 12:21:52 -0500
In-Reply-To: <1322630461.2596.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only reason I did it the way I did was I'd not yet gotten that far 
though the maze :)   I like your two-line *much* better and will test it 
today.

rick
