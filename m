From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 03/10] ixgbe: Fix typo
Date: Wed, 26 Jun 2013 07:51:55 -0700
Message-ID: <1372258315.2076.14.camel@joe-AO722>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1372244122-17664-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49423 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751355Ab3FZOv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 10:51:56 -0400
In-Reply-To: <1372244122-17664-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 03:55 -0700, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Fix a typo where the code should use a bitwise "and" rather than a logical
> "and".

This patch is bad because it should be rolled into 1/10
instead of sent as a separate patch.

I also think the subject line is poor.

It sounds like it's just a misspelling in a comment
or a dmesg instead of a logical error.
