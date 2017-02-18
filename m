From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v2 00/12] net: ethernet: aquantia: improvements
 and fixes
Date: Sat, 18 Feb 2017 12:56:23 +0100
Message-ID: <6a2027ff-6725-4e8e-99fb-34c58542c393@gmx.de>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:57207 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751632AbdBRMEj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 07:04:39 -0500
In-Reply-To: <cover.1487365317.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 17.02.2017 22:07, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> The following patchset contains improvements and fixes for aQuantia
> AQtion ethernet driver from net-next tree.
> 
> Most fixes are based on the comments from Lino Sanfilippo.
> 
> Sanity testing was performed on real HW. No regression found.
> 
> v1->v2 :Removed buffers copying.
> 	Fixed dma error handling.
> 
> 
> Please review.

You could have added all "reviewed-by" tags that you have received so
far for patches in the former version of this series. I think otherwise this 
information will get lost.

Regards,
Lino
