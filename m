From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: linux-next: merge of the wireless-next tree into the net-next
 tree
Date: Wed, 4 Jan 2012 20:50:19 +0200
Message-ID: <4F049F6B.3030900@qca.qualcomm.com>
References: <20120104105947.8bac77d1d7198a49e6feeca8@canb.auug.org.au>	<4F040799.7080604@qca.qualcomm.com> <20120104.132412.1376413566875687968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <sfr@canb.auug.org.au>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120104.132412.1376413566875687968.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/04/2012 08:24 PM, David Miller wrote:
> From: Kalle Valo <kvalo@qca.qualcomm.com>
> Date: Wed, 4 Jan 2012 10:02:33 +0200
> 
>> For a temporary solution I'll send a patch which forces ath6kl to
>> build only as a module and I'll send ath6kl_core.ko patches ASAP
>> after that.
> 
> That's not reasonable, fix it properly.

I will, I have the patches almost ready now. Will send them tonight.
Just wanted to send a quick fix first.

Sorry about the whole mess. I was sure that I compile tested the usb
code properly when I added them, but apparently I didn't.

Kalle
