From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Mon, 05 Nov 2012 01:44:37 -0500 (EST)
Message-ID: <20121105.014437.768714358664336963.davem@davemloft.net>
References: <CAFWqQMSes5J1bjUA6NBiWKrjbdUKJkhz-mdNYhGLU-A8cksxZg@mail.gmail.com>
	<20121105.005343.973313737817968846.davem@davemloft.net>
	<CAFWqQMRa6sPxqAJswu-6f06KxhqLSsY2T-dE3p-tpo4VEpwfdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: cardoe@cardoe.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFWqQMRa6sPxqAJswu-6f06KxhqLSsY2T-dE3p-tpo4VEpwfdA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Goldstein <cardoe@cardoe.com>
Date: Mon, 5 Nov 2012 00:19:19 -0600

> By this argument we shouldn't ever improve any API or add new syscalls
> since we'll have to have fallback code to handle the old interfaces
> when the new ones aren't available.

It makes sense to add new APIs when existing mechanisms are too
difficult _AND_ code doesn't already exist that works reasonable well
with existing facilities.
