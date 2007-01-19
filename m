From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Thu, 18 Jan 2007 22:05:02 -0500
Message-ID: <45B0355E.60705@garzik.org>
References: <20061220124125.6286.17148.stgit@localhost.localdomain> <45918CA4.3020601@garzik.org> <45A36C22.6010009@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47673 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964777AbXASDFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 22:05:05 -0500
To: Divy Le Ray <divy@chelsio.com>
In-Reply-To: <45A36C22.6010009@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> Jeff Garzik wrote:
>> Divy Le Ray wrote:
>>> From: Divy Le Ray <divy@chelsio.com>
>>>
>>> This patch implements the main header files of
>>> the Chelsio T3 network driver.
>>>
>>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>>
>> Once you think it's ready, email me a URL to a single patch that adds 
>> the driver to the latest linux-2.6.git kernel.  Include in the email a 
>> description of the driver and signed-off-by line, which will get 
>> directly included in the git changelog.
>>
>> Adding new drivers is a bit special, because we want to merge it as a 
>> single changeset, but that would create a patch too large to review on 
>> the common kernel mailing lists.
> Jeff,
> 
> You can grab the monolithic patch at this URL:
> http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

applied to netdev-2.6.git#upstream

I'm really counting on Chelsio to actively maintain this driver, unlike 
the abandonware you guys first submitted.

	Jeff



