From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v5 04/10] net: provide counter for tx_timeout
 errors in sysfs
Date: Wed, 16 Nov 2011 08:51:01 -0800
Message-ID: <20111116085101.246be084@s6510.linuxnetplumber.net>
References: <cover.1321420513.git.david.decotigny@google.com>
	<5517a18a0aaacf7ee91ee189825842a19905ffa4.1321420513.git.david.decotigny@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49661 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215Ab1KPQvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 11:51:05 -0500
In-Reply-To: <5517a18a0aaacf7ee91ee189825842a19905ffa4.1321420513.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Nov 2011 21:15:52 -0800
David Decotigny <david.decotigny@google.com> wrote:

> This adds the /sys/class/net/DEV/queues/Q/tx_timeout attribute
> containing the total number of timeout events on the given queue. It
> is always available, independently of CONFIG_RPS/XPS.
> 
> Credits to Stephen Hemminger for a preliminary version of this patch.

Cool I like it.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
