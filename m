From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH 8/8] fanotify: send events to userspace over socket
 reads
Date: Fri, 11 Sep 2009 07:32:31 -0700
Message-ID: <1252679551.30578.857.camel@desktop>
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
Received: from fifo99.com ([67.223.236.141]:48131 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752724AbZIKOb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 10:31:57 -0400
In-Reply-To: <1252678545.2305.4.camel@dhcp231-106.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-11 at 10:15 -0400, Eric Paris wrote:

> I will look at all of the my 80+ character lines again.  This one in
> particular, I will not break up.  I might read a little too broadly in
> CodingStyle where it says the "exception to this is where exceeding 80
> columns significantly increases readability and does not hide
> information".

There is a point when longer lines get too long tho .. Maybe over 100 is
too long.. Where if your terminal only displays 80 characters , and the
text is way over 80 the lines just get wrapped and all the intended
readability goes out the window.

Daniel

