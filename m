From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] drivers:net:wireless: Add mutex locking for function,
 b43_op_beacon_set_time in main.c
Date: Sat, 29 Nov 2014 12:54:17 -0600
Message-ID: <547A1659.9070605@lwfinger.net>
References: <1417213013-19758-1-git-send-email-xerofoify@gmail.com>	<CACna6rxmOC0h9hOpa=5iWFM1THQ8Q4hCi8MnmqkZJbB_U0PJ0A@mail.gmail.com>	<20141129002148.1beb21d9@wiggum>	<54793E4E.7050602@gmail.com>	<20141129095632.69361457@wiggum> <CACna6ryjZ-LY06wAMzoL77Wca3McUUT+VYsO4EPO87NqjBnaNw@mail.gmail.com> <547A0BC5.2080005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	b43-dev <b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: nick <xerofoify-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?B?TWljaGFlbCBCw7xzY2g=?= <m@bues.ch>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <547A0BC5.2080005-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/29/2014 12:09 PM, nick wrote:
> Sorry about that, next time I will be more careful.

One other thing would be to change the initial part of the subject. Yes, the 
device is in drivers/net/wireless/, but it is much more common to not include 
those in patches that are sent to Linville. I would have used "b43: Add ...". 
That catches the eye more quickly. As they say in the newspaper business, "Don't 
bury the lead."

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
