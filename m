From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: ieee802154-atusb: Delete an unnecessary check before the function
 call "kfree_skb"
Date: Fri, 11 Dec 2015 14:21:04 +0100
Message-ID: <566ACDC0.30201@osg.samsung.com>
References: <5307CAA2.8060406@users.sourceforge.net>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <564B5327.4010307@osg.samsung.com>
 <564B5344.1090200@osg.samsung.com> <56695093.8080605@osg.samsung.com>
 <7DCE62A2-DEA0-4ABF-A0D6-4EE00BDFFE95@holtmann.org>
 <566ACA84.6080603@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <alex.aring@gmail.com>, linux-wpan@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566ACA84.6080603@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/12/15 14:07, SF Markus Elfring wrote:
>> this slipped through, but now it does no longer apply.
>>
>> Applying: ieee802154-atusb: Delete an unnecessary check before the function call "kfree_skb"
>> error: patch failed: drivers/net/ieee802154/atusb.c:310
>> error: drivers/net/ieee802154/atusb.c: patch does not apply
>> Patch failed at 0001 ieee802154-atusb: Delete an unnecessary check before the function call "kfree_skb"
> How can this hiccup happen?
>

I might have been a problem when I was resending your patch the first 
time as Marcel was not able to find the original one.

I have send it a second time now and it worked fine. The patch is 
already applied to the bluetooth-next tree and thus on its way. All good 
now.

https://git.kernel.org/cgit/linux/kernel/git/bluetooth/bluetooth-next.git/commit/?id=4188146566a9f1d57dfce77fd9457f7304b69dfa

regards
Stefan Schmidt
