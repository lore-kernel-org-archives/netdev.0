From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] bluetooth: btusb: Fix issue with suspend
Date: Sat, 06 Sep 2014 14:05:39 -0500
Message-ID: <540B5B03.9070203@lwfinger.net>
References: <1409930194-6318-1-git-send-email-Larry.Finger@lwfinger.net> <6DF81E54-681F-4B18-95C7-F4684FF19786@holtmann.org> <540B4159.9000003@lwfinger.net> <D5B40282-A085-4B47-8F7B-27480CAB6B19@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <D5B40282-A085-4B47-8F7B-27480CAB6B19-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/06/2014 12:35 PM, Marcel Holtmann wrote:
> Hi Larry,
>
>
> one other thing. Please let maintainers decide when a patch is useful for stable and when not. Patches need to go upstream first anyway. People spamming stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org with patches that are not reviewed yet is pretty much a waste of time.

Sorry. In the wireless tree, the patch author suggests that the patch is 
suitable for stable. If the maintainer disagrees, he strips the Cc to stable. It 
seems that you do it the other way. In either case, I do not think the stable 
patches are picked up by the maintainers of stable versions until the patch hits 
mainline.

Larry
