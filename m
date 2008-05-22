From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] Restore multicast settings on resume
Date: Thu, 22 May 2008 06:21:14 -0400
Message-ID: <4835491A.1020209@garzik.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080518130035.GA21417@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemm
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59272 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936456AbYEVKVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:21:18 -0400
In-Reply-To: <20080518130035.GA21417@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:
> From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> 
> nv_open() resets multicast settings, call nv_set_multicast(dev) to restore them.
> (Maybe this should rather be moved into nv_open())
> 
> Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>

applied

Ayaz, have you reviewed the other patches in this series?


