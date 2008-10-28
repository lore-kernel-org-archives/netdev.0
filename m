From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: Coexist with the sysfs limitations v2
Date: Mon, 27 Oct 2008 17:50:55 -0700 (PDT)
Message-ID: <20081027.175055.208449244.davem@davemloft.net>
References: <m1fxmni9uv.fsf_-_@frodo.ebiederm.org>
	<20081027.124126.74749150.davem@davemloft.net>
	<m1skqh4wq8.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, serue@us.ibm.com, netdev@vger.kernel.org,
	gregkh@suse.de, viro@ftp.linux.org.uk, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, htejun@gmail.com, den@openvz.org,
	containers@lists.linux-foundation.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752052AbYJ1AvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 20:51:17 -0400
In-Reply-To: <m1skqh4wq8.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 27 Oct 2008 13:19:27 -0700

> What I was thinking is that it goes into your tree for 2.6.29.  Allowing
> for better test coverage in the short term, and removing the pressure
> to do a hack job on sysfs just to reduce the pain of testing.

Fair enough.  I'll add it to my tree.
