From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Mon, 05 Mar 2012 12:43:27 -0800
Message-ID: <1330980207.25997.2.camel@oc3660625478.ibm.com>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>
	 <1329519726-25763-2-git-send-email-aliguori@us.ibm.com>
	 <20120219144145.GA16620@redhat.com>
	 <OFC071CE44.FE2F733D-ON862579AA.0055FCA0-862579AA.0057082B@us.ibm.com>
	 <20120220192708.GA18308@redhat.com> <4F42A2FB.7000501@us.ibm.com>
	 <20120220210005.GA19278@redhat.com>
	 <1329786250.13141.9.camel@localhost.localdomain>
	 <20120221032147.GB2502@redhat.com>
	 <1329796998.13141.26.camel@localhost.localdomain>
	 <4F54BDE9.5080505@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <aliguori@us.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>, netdev@vger.kernel.org,
	Cristian Viana <vianac@br.ibm.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:59777 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757496Ab2CEUnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 15:43:35 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Mon, 5 Mar 2012 13:43:35 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 59BC2C90065
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2012 15:43:31 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KhVfW237840
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2012 15:43:31 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KhUXr027800
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2012 13:43:30 -0700
In-Reply-To: <4F54BDE9.5080505@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-05 at 07:21 -0600, Anthony Liguori wrote:
> Hi Shirley,
> 
> Are you planning on posting these patches soon?
> 
> Regards,
> 
> Anthony Liguori

I thought to compare with different scheduling with different NICs
before submitting it. Maybe it's better to submit a RFC patch to get
review comments now. Let me clean up the patch and submit it here.

Thanks
Shirley
