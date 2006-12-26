From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 26 Dec 2006 15:57:08 -0500
Message-ID: <45918CA4.3020601@garzik.org>
References: <20061220124125.6286.17148.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41270 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932780AbWLZU5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 15:57:11 -0500
To: Divy Le Ray <None@chelsio.com>
In-Reply-To: <20061220124125.6286.17148.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> This patch implements the main header files of
> the Chelsio T3 network driver.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Once you think it's ready, email me a URL to a single patch that adds 
the driver to the latest linux-2.6.git kernel.  Include in the email a 
description of the driver and signed-off-by line, which will get 
directly included in the git changelog.

Adding new drivers is a bit special, because we want to merge it as a 
single changeset, but that would create a patch too large to review on 
the common kernel mailing lists.

	Jeff



