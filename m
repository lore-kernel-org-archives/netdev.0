From: Aaron Brown <aaron.f.brown@intel.com>
Subject: Re: [PATCH net-next] intel: Remove unnecessary OOM messages
Date: Wed, 12 Feb 2014 15:46:12 -0800
Message-ID: <1392248772.1818.5.camel@localhost>
References: <1392168397.23721.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39180 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269AbaBLXqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 18:46:16 -0500
In-Reply-To: <1392168397.23721.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-11 at 17:26 -0800, Joe Perches wrote:
> Don't emit these as there's a generic OOM with a dump_stack()
> on allocation failures.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

Thanks Joe, I have added this to Jeff's queue.
