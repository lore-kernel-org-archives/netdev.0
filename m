From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next] net/fm10k: Avoid double setting of NETIF_F_SG
 for the HW encapsulation feature mask
Date: Sun, 9 Nov 2014 10:15:05 +0200
Message-ID: <545F2289.1090802@mellanox.com>
References: <1415265664-10738-1-git-send-email-ogerlitz@mellanox.com> <D0827E2E.5ED4E%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog124.obsmtp.com ([207.126.144.157]:51507 "EHLO
	eu1sys200aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750769AbaKIIPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 03:15:11 -0500
In-Reply-To: <D0827E2E.5ED4E%matthew.vick@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/7/2014 11:57 PM, Vick, Matthew wrote:
> Good catch, Or! Thank you for taking care of this!

sure
> Someone can correct me if I'm mistaken (I thought checkpatch would
> complain about this, but it doesn't seem to be), but I believe the start
> of the lines should match up like they are for the dev->features. Would
> you like to submit a V2 with this change or would you like me to do it
> (giving you credit via your Reported-by)?

I just submitted V1 along your request
