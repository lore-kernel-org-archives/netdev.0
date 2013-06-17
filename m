From: David Miller <davem@davemloft.net>
Subject: Re: Patches required for 3.9 stable
Date: Mon, 17 Jun 2013 13:20:57 -0700 (PDT)
Message-ID: <20130617.132057.1873879604917526327.davem@davemloft.net>
References: <51BEC1C3.40109@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org, mst@redhat.com,
	jwboyer@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab3FQUVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 16:21:00 -0400
In-Reply-To: <51BEC1C3.40109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 17 Jun 2013 15:58:59 +0800

> Hi Greg:
> 
> Please include the following commits into 3.9.y. Which fixes:
> 
> 1) Crash when sending GSO packets from untrusted sources
> 9b4d669bc06c215d64f56f1eb0d4eb96e14d689d
> 38502af77e07b5d6650b9ff99a0b482d86366592
> c1aad275b0293d2b1905ec95a945422262470684
> f9ca8f74399f9195fd8e01f67a8424a8d33efa55
> 15e5a030716468dce4032fa0f398d840fa2756f6
> 
> 2) Can't create a multiqueue tap
> e8dbad66ef56074eadb41ed5998acd2320447018
> 
> All can be cheery-picked and I have tested them.

I'm currently working on stable submissions for networking.  The
person to ask for this kind of stuff is me, not Greg.
