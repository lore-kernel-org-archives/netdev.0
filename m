From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-06-22
Date: Fri, 22 Jun 2012 16:55:31 -0700 (PDT)
Message-ID: <20120622.165531.386085974835484549.davem@davemloft.net>
References: <20120622201716.GB13918@tuxdriver.com>
	<20452.64701.760819.559191@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: c_manoha@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20452.64701.760819.559191@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Date: Sat, 23 Jun 2012 04:46:13 +0530

> John W. Linville wrote:
>> Mohammed Shafi Shajakhan (1):
>>       ath9k_hw: avoid possible infinite loop in ar9003_get_pll_sqsum_dvc
> 
> Um, this commit doesn't really fix anything - the timeout is also
> arbitrary. Can you remove this from the 3.5 queue ? Thanks.

Not possible, already pushed out.
