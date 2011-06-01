From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next-2.6 v2] bonding: allow resetting slave failure
 counters
Date: Wed, 01 Jun 2011 13:41:03 -0300
Message-ID: <4DE66B9F.9090205@redhat.com>
References: <1306921249-3623-1-git-send-email-jpirko@redhat.com> <4DE63E85.7020508@redhat.com> <20110601135321.GA2909@psychotron.brq.redhat.com> <16056.1306944819@death> <20110601163153.GB2784@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758556Ab1FARHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 13:07:32 -0400
In-Reply-To: <20110601163153.GB2784@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2011 01:31 PM, Jiri Pirko wrote:
> This patch allows to reset failure counters for all enslaved devices.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> v1->v2: added version bump
> 	added version note to doc
> 	moved and adjusted printk
> ---
>  Documentation/networking/bonding.txt |    9 +++++++++
>  drivers/net/bonding/bond_sysfs.c     |   28 ++++++++++++++++++++++++++++
>  drivers/net/bonding/bonding.h        |    4 ++--
>  3 files changed, 39 insertions(+), 2 deletions(-)

Reviewed-by: Flavio Leitner <fbl@redhat.com>
Thanks!
fbl
