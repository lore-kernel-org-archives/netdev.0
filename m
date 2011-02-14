From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull request: wireless-2.6 2011-02-14
Date: Mon, 14 Feb 2011 22:12:22 +0100
Message-ID: <1297717942.3953.9.camel@jlt3.sipsolutions.net>
References: <20110214204406.GG2722@tuxdriver.com>
	 <20110214.125148.59672184.davem@davemloft.net>
	 <20110214.130056.115934219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110214.130056.115934219.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-02-14 at 13:00 -0800, David Miller wrote:

> Please address this newly introduced warning in a future pull request,
> thanks:
> 
> drivers/net/wireless/iwlwifi/iwl-3945.c:411:13: warning: 'iwl3945_good_plcp_health' defined but not used

The function can simply be deleted.

johannes
