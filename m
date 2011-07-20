From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH net-next]vhost: fix condition check for # of
 outstanding dma buffers
Date: Wed, 20 Jul 2011 09:49:00 -0700
Message-ID: <1311180540.8573.39.camel@localhost.localdomain>
References: <1311100678.8573.16.camel@localhost.localdomain>
	 <20110719190945.GB8667@redhat.com>
	 <1311108985.8573.30.camel@localhost.localdomain>
	 <20110720102831.GA5164@redhat.com>
	 <1311176589.8573.33.camel@localhost.localdomain>
	 <20110720161721.GD8077@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:57768 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab1GTQtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 12:49:13 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6KFdJ8F008818
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 09:39:19 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6KGn3ld092826
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 10:49:05 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6KAn2XR016973
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 04:49:02 -0600
In-Reply-To: <20110720161721.GD8077@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-20 at 19:17 +0300, Michael S. Tsirkin wrote:
> My point was that the logic isn't the same, even though
> you said 'it is equal to'.
> Same applies to upend_idx == 1, done_idx == 0.

:) not sure what I was thinking.

I will resubmit the patch.

Thanks
Shirley


