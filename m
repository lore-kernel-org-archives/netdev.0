From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH RFC] virtio_net: use NAPI for xmit (UNTESTED)
Date: Tue, 30 Mar 2010 22:44:44 -0700
Message-ID: <1270014284.25337.3.camel@localhost.localdomain>
References: <201003311429.57793.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:35303 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006Ab0CaFos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:44:48 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2V5hEOA006308
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:43:14 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2V5ikTb144734
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:44:46 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2V5ijBP029411
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:44:46 -0600
In-Reply-To: <201003311429.57793.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Rusty,

On Wed, 2010-03-31 at 14:29 +1030, Rusty Russell wrote:
> I don't have time to chase this, but it's been sitting in my patch
> queue
> for a while.  Wondered if Michael or Shirley wanted to toy with it
> 

Does this patch build on top of net-next-2.6?

Shirley

