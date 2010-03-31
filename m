From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] virtio_net: avoid BUG_ON() with large packets when
 CONFIG_DEBUG_SG=y
Date: Tue, 30 Mar 2010 22:39:44 -0700
Message-ID: <1270013984.25337.1.camel@localhost.localdomain>
References: <201003301526.35720.rusty@rustcorp.com.au>
	 <20100329.220859.94049113.davem@davemloft.net>
	 <201003311105.19014.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mst@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:60458 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756623Ab0CaFjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:39:48 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2V5ak6F028959
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:36:46 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2V5dlBU066138
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:39:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2V5dki4017174
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:39:46 -0600
In-Reply-To: <201003311105.19014.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 11:05 +1030, Rusty Russell wrote:
> Shirley, please cc me in future.

I will. I thought you might be on vacation. :)

Shirley

