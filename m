From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: atlx, fix memory leak
Date: Thu, 07 Jan 2010 01:05:06 -0800 (PST)
Message-ID: <20100107.010506.165517428.davem@davemloft.net>
References: <1262796856-21919-1-git-send-email-jslaby@suse.cz>
	<20100106182830.4bd861fe@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jslaby@suse.cz, linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	chris.snook@gmail.com, jie.yang@atheros.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jcliburn@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932760Ab0AGJFD@vger.kernel.org>
In-Reply-To: <20100106182830.4bd861fe@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: J K Cliburn <jcliburn@gmail.com>
Date: Wed, 6 Jan 2010 18:28:30 -0600

> On Wed,  6 Jan 2010 17:54:16 +0100
> Jiri Slaby <jslaby@suse.cz> wrote:
> 
>> Stanse found a memory leak in atl2_get_eeprom. eeprom_buff is not
>> freed/assigned on all paths. Fix that.
> 
> Acked by: Jay Cliburn <jcliburn@gmail.com>

Applied, thanks.
