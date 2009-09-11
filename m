From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH 8/8] fanotify: send events to userspace over socket
 reads
Date: Fri, 11 Sep 2009 07:22:18 -0700
Message-ID: <1252678938.30578.851.camel@desktop>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911052649.32359.18553.stgit@paris.rdu.redhat.com>
	 <1252678130.30578.848.camel@desktop>
	 <1252678545.2305.4.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fifo99.com ([67.223.236.141]:57823 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752563AbZIKOVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 10:21:44 -0400
In-Reply-To: <1252678545.2305.4.camel@dhcp231-106.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-11 at 10:15 -0400, Eric Paris wrote:

> I will look at all of the my 80+ character lines again.  This one in
> particular, I will not break up.  I might read a little too broadly in
> CodingStyle where it says the "exception to this is where exceeding 80
> columns significantly increases readability and does not hide
> information".

Yeah, it's ok if you don't break up any, or just do some. The fewer long
lines tho the cleaner it is I think.

Daniel

