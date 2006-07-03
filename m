From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [RFC DECNET 04/04]: Increase number of possible routing tables to 2^32
Date: Mon, 3 Jul 2006 12:20:12 +0100
Message-ID: <20060703112012.GA24742@souterrain.chygwyn.com>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <20060703075305.6286.18061.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	greearb@candelatech.com,
	Patrick Caulfield <patrick@tykepenguin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from souterrain.chygwyn.com ([194.39.143.233]:44228 "EHLO
	souterrain.chygwyn.com") by vger.kernel.org with ESMTP
	id S1750888AbWGCLRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 07:17:33 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20060703075305.6286.18061.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Jul 03, 2006 at 09:53:05AM +0200, Patrick McHardy wrote:
> [DECNET]: Increase number of possible routing tables to 2^32
> 
> Increase the nubmer of possible routing tables to 2^32 by replacing the
> fixed sized array of tables by a hash table.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
>
I've had a quick look though the DECnet parts of this and it looks good,
atthough I've not had a chance to test it at all. Please cc Patrick Caulfield
on DECnet changes,

Steve.
 
