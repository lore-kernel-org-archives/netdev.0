From: Aaron Sethman <androsyn@ratbox.org>
Subject: Re: [OOPS] bcm43xx oops on 2.6.20-rc1 on x86_64
Date: Sat, 30 Dec 2006 23:14:38 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0612302312520.27190@squeaker.ratbox.org>
References: <Pine.LNX.4.64.0612171510030.17532@squeaker.ratbox.org>
 <20061230192104.GB20714@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, Larry.Finger@lwfinger.net,
	st3@riseup.net, linville@tuxdriver.com, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932720AbWLaEOk@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061230192104.GB20714@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sat, 30 Dec 2006, Adrian Bunk wrote:

> On Sun, Dec 17, 2006 at 03:15:28PM -0500, Aaron Sethman wrote:
>>
>> Just was loading the bcm43xx module and got the following oops. Note that
>> this card is one of the newer PCI-E cards.  If any other info is needed
>> let me know.
>
> Is this issue still present in 2.6.10-rc2-git1?
>
> If yes, was 2.6.19 working fine?
>

This seems to be fixed in 2.6.20-rc2-git1.  Still having other issues 
with the driver, but the oops in the SoftMAC code is resolved now at 
least.

-Aaron
