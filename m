From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipv4: Only destroy inet devices when we receive an NETDEV_UNREGISTER event
Date: Fri, 22 Jun 2007 03:07:17 -0600
Message-ID: <m1d4zocq7u.fsf@ebiederm.dsl.xmission.com>
References: <m17ipwebhh.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:38175 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbXFVJHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 05:07:23 -0400
In-Reply-To: <m17ipwebhh.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's
	message of "Fri, 22 Jun 2007 00:42:34 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Never mind.  I saw this and I thought it was an old obscure bug.
But it appears it is a new condition, that has already been
fixed.

Eric


