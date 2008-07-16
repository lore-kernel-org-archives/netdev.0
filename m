From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds
 want to know why its set to zero)
Date: Wed, 16 Jul 2008 14:22:19 -0500
Message-ID: <487E4A6B.6040103@linux-foundation.org>
References: <OF4F3F2DB0.24836443-ON88257488.0068C9C1-88257488.0068F7AD@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46470 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756604AbYGPTXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 15:23:14 -0400
In-Reply-To: <OF4F3F2DB0.24836443-ON88257488.0068C9C1-88257488.0068F7AD@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> Oops, I didn't see all of your message when I replied....
> 
> But the explanation is still true. I don't think we should put an ID
> on every packet.

Wasnt there a time when we did IP_ID on every packet? Any changelogs from that time?

