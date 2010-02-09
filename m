From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ip: print "temporary" for IPv6 temp addresses
Date: Tue, 9 Feb 2010 11:06:21 -0800
Message-ID: <20100209110621.49701a12@nehalam>
References: <4AAEAF37.7020305@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39337 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436Ab0BITGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 14:06:32 -0500
In-Reply-To: <4AAEAF37.7020305@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Sep 2009 17:01:43 -0400
Brian Haley <brian.haley@hp.com> wrote:

> IPv6 addresses that have IFA_F_SECONDARY set are actually temporary addresses,
> hence the IFA_F_TEMPORARY equivalent.  Change the output in this case and
> allow filtering on the word "temporary".
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied (for 2.6.33)


-- 
