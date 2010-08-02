From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in kernel
Date: Mon, 02 Aug 2010 16:51:14 +0300
Message-ID: <4C56CD52.1080600@gmail.com>
References: <AANLkTik7powjUaJ51bA_bgPVb03U-RVZay3NffHBYLzx@mail.gmail.com> <AANLkTik5qnmHALi7=AMA+Lai6a+9STgub9BnQAV6EVkh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hp fk <fkhp101@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darkstar.wilibox.com ([195.14.175.138]:47668 "EHLO
	darkstar.wilibox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab0HBOBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 10:01:12 -0400
In-Reply-To: <AANLkTik5qnmHALi7=AMA+Lai6a+9STgub9BnQAV6EVkh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2010 04:16 PM, hp fk wrote:
> ---------- Forwarded message ----------
> From: hp fk<fkhp101@gmail.com>
> Date: 2010/8/2
> Subject: a Great Idea - include Kademlia networking protocol in kernel
> To: linux-kernel@vger.kernel.org
>
>
> Kademlia protocol is widely used by many p2p applications, if kernel
> support the Kademlia protocol and its p2p network infrastracture. it
> will be easier to bring us into a new stage of network with much more
> freedom and equality.
>
> 1.systems could get public identity on network much more easier, and
> need not depend on DNS system, which usual controled by buraucracy
> agents.
> 2. system presence on network is easier to resolved in a dynamic ip
> environment that many ISPs use to effectively use IP address. and
> communication could be much easier.
> 3.many p2p applications could be releaved from building the p2p
> network infrastracture repeatedly and focus on application features.
> 4. some restrictions imposed by buraucracy censorship will be breaked
> and give us much more communication freedom
> 5. all linux systems could be equal citizens of a unified greate linux
> p2p network and promote the development of p2p network.

I don't see any valid point why it should be done in kernel and not
in userspace. Actually doing this in userspace is better since it
would allow you to support other OS like BSD, Windows and etc.
