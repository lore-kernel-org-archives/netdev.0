From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH RFC] virtio_net: use NAPI for xmit (UNTESTED)
Date: Tue, 30 Mar 2010 22:58:13 -0700
Message-ID: <1270015094.25337.4.camel@localhost.localdomain>
References: <201003311429.57793.rusty@rustcorp.com.au>
	 <1270014284.25337.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:37501 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab0CaF6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:58:16 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2V5n4mg029509
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:49:04 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2V5wF98147946
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 23:58:15 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2UMwFvE024537
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 16:58:15 -0600
In-Reply-To: <1270014284.25337.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back ported it and prepared for more tests.

Shirley

