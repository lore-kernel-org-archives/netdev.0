From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [net-next 13/14] igb: Don't give VFs random MAC addresses
Date: Mon, 28 Jan 2013 12:09:31 +0100
Message-ID: <51065C6B.5020503@redhat.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com> <1359363869-32391-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205Ab3A1LJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 06:09:41 -0500
In-Reply-To: <1359363869-32391-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.01.2013 10:04, Jeff Kirsher wrote:
> From: Mitch A Williams <mitch.a.williams@intel.com>
> 
> If the user has not assigned a MAC address to a VM, then don't give it a
> random one. Instead, just give it zeros and let it figure out what to do
> with them.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Stefan Assmann <sassmann@kpanic.de>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Tested-by: Stefan Assmann <sassmann@redhat.com>

  Stefan
