From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth: btusb: Fix issue with suspend
Date: Sat, 6 Sep 2014 12:12:44 -0700
Message-ID: <9F1659DE-61C2-4CA9-8696-16F120273154@holtmann.org>
References: <1409930194-6318-1-git-send-email-Larry.Finger@lwfinger.net> <6DF81E54-681F-4B18-95C7-F4684FF19786@holtmann.org> <540B4159.9000003@lwfinger.net> <D5B40282-A085-4B47-8F7B-27480CAB6B19@holtmann.org> <540B5B03.9070203@lwfinger.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Champion Chen <champion_chen@realsil.com.cn>,
	Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <540B5B03.9070203@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Larry,

>> one other thing. Please let maintainers decide when a patch is useful for stable and when not. Patches need to go upstream first anyway. People spamming stable@vger.kernel.org with patches that are not reviewed yet is pretty much a waste of time.
> 
> Sorry. In the wireless tree, the patch author suggests that the patch is suitable for stable. If the maintainer disagrees, he strips the Cc to stable. It seems that you do it the other way. In either case, I do not think the stable patches are picked up by the maintainers of stable versions until the patch hits mainline.

I have no idea what the stable@vger.kernel.org guys do with patches that are not yet upstream. However it is a waste of their time sending stuff to their mailing list that has not even seen a maintainer review. You can just mention it in the comment section that this might qualify for stable.

Regards

Marcel
