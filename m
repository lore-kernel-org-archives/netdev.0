From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: net: sctp: rework multihoming retransmission path selection to
 rfc4960
Date: Thu, 06 Mar 2014 10:42:12 +0100
Message-ID: <531842F4.9070709@redhat.com>
References: <20140305192635.6D9F7660D13@gitolite.kernel.org> <20140306060232.GA26578@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-coverity@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087AbaCFJm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 04:42:26 -0500
In-Reply-To: <20140306060232.GA26578@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2014 07:02 AM, Dave Jones wrote:
...
> Either the check is redundant, or it needs to be moved up.

Yep, first one.

I already have a patch in my local tree, will send it out
some time this week.

Cheers,

Daniel
