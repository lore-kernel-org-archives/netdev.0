From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix_diag: use netlink attribute MAX convention
Date: Wed, 25 Apr 2012 15:57:17 -0400 (EDT)
Message-ID: <20120425.155717.2099319998110521099.davem@davemloft.net>
References: <20120425115609.4ef9ece0@nehalam.linuxnetplumber.net>
	<20120425.150716.1476178549121153876.davem@davemloft.net>
	<20120425124743.5b4fb8a3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei88@gmail.com, xemul@parallels.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758135Ab2DYT5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 15:57:24 -0400
In-Reply-To: <20120425124743.5b4fb8a3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 25 Apr 2012 12:47:43 -0700

> On Wed, 25 Apr 2012 15:07:16 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> Either you apply them as soon as possible, or you mark them
>> appropriately as "Changes Requested" or "Deferred" so that the
>> submitter makes appropriate fixes you've asked for, or resubmits when
>> it's more appropriate for the change to go in.
>> 
>> "Under Review" doesn't mean, "I'm waiting for a kernel release with
>> the feature".  But that's how you use it.
> 
> Ok. What is the suggested tag for that.

As I said above, "Deferred", with a note sent to the submitter to resubmit
the patch at the appropriate time.
