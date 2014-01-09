From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/3] bonding: cleanup bond_3ad.c
Date: Thu, 9 Jan 2014 09:36:39 +0800
Message-ID: <52CDFD27.50400@huawei.com>
References: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2947 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbaAIBg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 20:36:59 -0500
In-Reply-To: <1389196008-28578-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/8 23:46, Veaceslav Falico wrote:
> It's a huge mess there currently - and, thus, really hard to read and
> debug.
> 
> This is the first series, and doesn't change the logic at all, only makes
> it a bit more readable.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> 
> ---
>  drivers/net/bonding/bond_3ad.c | 731 +++++++++++++++++++++--------------------
>  1 file changed, 366 insertions(+), 365 deletions(-)
> 

Great work!

Tested-by: Ding Tianhong <dingtianhong@huawei.com>
