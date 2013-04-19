From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC/RFT PATCH 2/2] rtk_btusb: A new driver for the Bluetooth
 portion of the Realtek RTL8723AE chip
Date: Thu, 18 Apr 2013 20:31:03 -0500
Message-ID: <51709E57.7020402@lwfinger.net>
References: <1365469068-4548-1-git-send-email-Larry.Finger@lwfinger.net> <1365469068-4548-3-git-send-email-Larry.Finger@lwfinger.net> <20130418222221.GA15279@joana>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130418222221.GA15279@joana>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/18/2013 05:22 PM, Gustavo Padovan wrote:
>
> We recently added a setup callback to btusb to run device specific
> initialization, take a look in bluetooth-next to check how that can help you
> avoid duplicate a lot of code.

Thanks for the tip. I knew something was in the planning stage.

Is there any documentation on using the new facility?

Larry
