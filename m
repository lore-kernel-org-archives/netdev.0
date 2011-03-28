From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Sun, 27 Mar 2011 18:09:22 -0700 (PDT)
Message-ID: <20110327.180922.59673799.davem@davemloft.net>
References: <m1wrjsi2tf.fsf@fess.ebiederm.org>
	<1300743744.2837.7.camel@edumazet-laptop>
	<m1hbawi15z.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com, arnd@arndb.de, kaber@trash.net
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39892
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752929Ab1C1BKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:10:01 -0400
In-Reply-To: <m1hbawi15z.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 21 Mar 2011 15:00:56 -0700

> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
>> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
>> discussion ?
> 
> No.  It seems I missed it, but I do have the same problem, and
> essentially the same fix. 

Can someone work on getting this straightened out and resubmit the
final patch so I can apply something?

Thanks.
