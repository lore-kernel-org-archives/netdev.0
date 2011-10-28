From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use flush_delayed_work_sync
 in bond_close
Date: Thu, 27 Oct 2011 23:15:20 -0400 (EDT)
Message-ID: <20111027.231520.698587739433841485.davem@davemloft.net>
References: <4EA4E2EE.4050201@hitachi.com>
	<2216.1319650260@death>
	<4EAA0ADF.5020504@hitachi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	shemminger@vyatta.com, andy@greyhouse.net,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: mitsuo.hayasaka.hu@hitachi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EAA0ADF.5020504@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Date: Fri, 28 Oct 2011 10:52:31 +0900

> I checked your patch, and any problems have not been observed for
> almost one day although I could reproduce the BUG in the latest net-next
> without it. 
> 
> I think this patch works well.
> 
> Tested-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>

Jay, please formally submit this patch with proper signoffs etc.

Thanks!
