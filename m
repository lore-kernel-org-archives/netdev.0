From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC DECNET 04/04]: Increase number of possible routing tables
 to 2^32
Date: Mon, 03 Jul 2006 13:21:26 +0200
Message-ID: <44A8FDB6.70603@trash.net>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <20060703075305.6286.18061.sendpatchset@localhost.localdomain> <20060703112012.GA24742@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	greearb@candelatech.com,
	Patrick Caulfield <patrick@tykepenguin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50909 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751103AbWGCLV2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 07:21:28 -0400
To: Steven Whitehouse <steve@chygwyn.com>
In-Reply-To: <20060703112012.GA24742@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Whitehouse wrote:
> Hi,
> 
> On Mon, Jul 03, 2006 at 09:53:05AM +0200, Patrick McHardy wrote:
> 
>>[DECNET]: Increase number of possible routing tables to 2^32
>>
>>Increase the nubmer of possible routing tables to 2^32 by replacing the
>>fixed sized array of tables by a hash table.
>>
>>Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
> I've had a quick look though the DECnet parts of this and it looks good,
> atthough I've not had a chance to test it at all. Please cc Patrick Caulfield
> on DECnet changes,

Thanks, will do on the next submission.

