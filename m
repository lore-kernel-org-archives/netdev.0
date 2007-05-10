From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 13:15:15 -0700
Message-ID: <46437D53.7000209@gmail.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com> <46435412.50800@hp.com> <1178820423.17393.3.camel@w-sridhar2.beaverton.ibm.com> <464375F9.1050600@gmail.com> <1178827887.4062.90.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Rick Jones <rick.jones2@hp.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:39106 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752595AbXEJUPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:15:16 -0400
In-Reply-To: <1178827887.4062.90.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:

> You would need to almost re-write the driver to make sure it does IO
> which is taking advantage of the batching.

Really! It's just the transmit routine. How radical can that be?

--
Gagan
