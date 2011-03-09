From: David Miller <davem@davemloft.net>
Subject: Re: [V2 Patch] bonding: move procfs code into bond_procfs.c
Date: Wed, 09 Mar 2011 13:34:39 -0800 (PST)
Message-ID: <20110309.133439.246540302.davem@davemloft.net>
References: <1299484726-29905-1-git-send-email-amwang@redhat.com>
	<20110307161740.GT11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110307161740.GT11864@gospo.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>
Date: Mon, 7 Mar 2011 11:17:40 -0500

> On Mon, Mar 07, 2011 at 03:58:46PM +0800, Amerigo Wang wrote:
>> V2: Move #ifdef CONFIG_PROC_FS into bonding.h, as suggested by David.
>> 
>> bond_main.c is bloating, separate the procfs code out,
>> move them to bond_procfs.c
>> 
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>> 
> 
> Looks good and works as expected.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

Applied, thanks everyone.
