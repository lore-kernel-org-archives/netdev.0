From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds want to
 know why its set to zero)
Date: Wed, 16 Jul 2008 12:06:33 -0700
Message-ID: <OF4F3F2DB0.24836443-ON88257488.0068C9C1-88257488.0068F7AD@us.ibm.com>
References: <OF5F2AB2D4.EAFD2016-ON88257488.0067DC0C-88257488.0068AE15@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Christoph Lameter <cl@linux-foundation.org>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:51995 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbYGPTGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 15:06:52 -0400
In-Reply-To: <OF5F2AB2D4.EAFD2016-ON88257488.0067DC0C-88257488.0068AE15@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops, I didn't see all of your message when I replied....

But the explanation is still true. I don't think we should put an ID
on every packet.

                                                +-DLS

