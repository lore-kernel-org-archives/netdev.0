From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH RESEND V3 net-next 2/3] net: huawei_cdc_ncm: Introduce
 the huawei_cdc_ncm driver
Date: Tue, 27 Aug 2013 08:52:57 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1308270843060.5658@eeeadesso>
References: <1377549913.1877.12.camel@joe-AO722> <20130826.165831.112649899191508957.davem@davemloft.net> <1377551155.1877.18.camel@joe-AO722> <20130826.170922.2228024390320689580.davem@davemloft.net> <1377552303.1877.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, mrkiko.rs@gmail.com,
	gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377552303.1877.23.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi guys!! :)
First of all - I would like to thank both of you for your interest and time in 
my patches.

I agree with Joe's point of view, completely. The Coding style document tries 
to leverage on the developer's good sense, even when defining some rules.
Apart from that - checkpatch.po informed me about those very long lines, but I 
decided to leave them as they are due to the fact that they would look even 
more horrible than they look now. My braille display is 80-chars long (at 
least, the one I use normally), so I understand very well the problem of not 
passing that limit. Even so, the coding style says you might do so if you think 
the code is more readable this way, and that's why.
My git usage is very bad as you may have observed (and I'm working on improving 
myself of course), but this was something I took into consideration.
I remember when this cameto discussion:
http://lkml.org/lkml/2009/12/17/229
still I know perfectly that one of the line you're blaming is indeed 139 
characters.
I understand and appreciate the fact that we _shouldn't_ take as reference 
worst cases (but only bbetter cases) to improve our practice & life, but in 
various drivers you can find examples like those.
Is this still a problem?

I will re-work the code and send the patch again as soon as I can.

thank you again!
