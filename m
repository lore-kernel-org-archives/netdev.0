From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-06-06
Date: Wed, 12 Jun 2013 00:42:41 -0700 (PDT)
Message-ID: <20130612.004241.761719664465563112.davem@davemloft.net>
References: <20130611.222706.1492583255605214982.davem@davemloft.net>
	<20130612.002103.916991474696226731.davem@davemloft.net>
	<20920.8752.339655.254147@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sujith@msujith.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20920.8752.339655.254147@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sujith Manoharan <sujith@msujith.org>
Date: Wed, 12 Jun 2013 12:54:32 +0530

> David Miller wrote:
>> John, I also don't like the ATK9K Kconfig option name change added in
>> this pull request, this is exactly the kind of thing that drives
>> Linus insane.
>> 
>> Change the default, fine, but changing the name is unnecssary churn
>> and adds a new config prompt that people are going to respond to
>> incorrectly when they type "make oldconfig"
> 
> This was Linus' suggestion: https://patchwork.kernel.org/patch/2676971/
> 
> The RH bugzilla appears to be down at the moment, but more background
> for the bug is here: https://bugzilla.redhat.com/show_bug.cgi?id=927191

Fair enough, I rescind my objection.
