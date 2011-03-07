From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [V2 Patch] bonding: move procfs code into bond_procfs.c
Date: Mon, 7 Mar 2011 11:17:40 -0500
Message-ID: <20110307161740.GT11864@gospo.rdu.redhat.com>
References: <1299484726-29905-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1299484726-29905-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 07, 2011 at 03:58:46PM +0800, Amerigo Wang wrote:
> V2: Move #ifdef CONFIG_PROC_FS into bonding.h, as suggested by David.
> 
> bond_main.c is bloating, separate the procfs code out,
> move them to bond_procfs.c
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 

Looks good and works as expected.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
