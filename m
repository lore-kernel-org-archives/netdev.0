From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH] netns: Teach the igmp code to handle multiple
	namespaces
Date: Sat, 12 Jul 2008 10:58:25 +0400
Message-ID: <1215845905.8316.4.camel@iris.sw.ru>
References: <m1od54dwar.fsf@frodo.ebiederm.org>
	 <m1zloocgd8.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19848 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbYGLG5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2008 02:57:40 -0400
In-Reply-To: <m1zloocgd8.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-11 at 13:31 -0700, Eric W. Biederman wrote:
> It turns out that I actually need working multicast reception in my
> test environment, not something that just the something that doesn't
> crash when a multicast packet comes in.
> 
> So on top of my previous patch that kept the kernel from crashing
> when multicast frames come it.  Actual support for receiving multicast
> data in a network namespace.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Denis V. Lunev <den@openvz.org>

