From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2012-03-08
Date: Wed, 07 Mar 2012 22:57:52 -0800 (PST)
Message-ID: <20120307.225752.1535997011608677011.davem@davemloft.net>
References: <20120308054431.GE3998@joana>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gustavo@padovan.org, johan.hedberg@gmail.com, marcel@holtmann.org,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org
To: padovan@profusion.mobi
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120308054431.GE3998@joana>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gustavo Padovan <padovan@profusion.mobi>
Date: Thu, 8 Mar 2012 02:44:31 -0300

> Hi Dave,
> 
> Here goes another try to merge the bluetooth-next changes. I looked to the
> whole diff of the last pull request and fixed all the style issues you
> reported in last pull request attempt. The diff is very big, so I may have
> missed some places, but we are, from your coding style point of view, in a
> much better state than before.
> 
> Please take a look on it and pull if you find the code suitable, otherwise
> tell me what's wrong and how we should fix it since your coding style rules
> are not written in CodingStyle.
> 
> About the patches:
>  - almost half of the patches is in the new Bluetooth Management interface, it
>  finally reached a stable state regarding its API and we now enable it by
>  default.
>  - lots of Bluetooth LE patches. This implementation is still unstable but
>    disabled by default.
>  - some L2CAP layer refactoring to make our core code more generic and
>    reusable.
>  - New HCI monitor interface to monitor Bluetooth flow.
>  - Lot of fixes and clean ups all over the Bluetooth subsystem.

Pulled, thanks a lot.
