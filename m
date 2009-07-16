From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 7/8] rt2x00: Use %pM conversion specifier
Date: Thu, 16 Jul 2009 13:35:54 -0700
Message-ID: <43e72e890907161335m4a6b6e7cx1aa945181eb408e3@mail.gmail.com>
References: <1247734839-21394-1-git-send-email-klto@zhaw.ch>
	<200907162227.30362.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Tobias Klauser <klto-xXYtEe5Xh1A@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
To: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200907162227.30362.IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2009 at 1:27 PM, Ivo van Doorn<ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thursday 16 July 2009, Tobias Klauser wrote:
>> Use the %pM conversion specifier for printk instead of print_mac.
>>
>> Signed-off-by: Tobias Klauser <klto-xXYtEe5Xh1A@public.gmane.org>
>
> Acked-by: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Johannes already has a patch for this posted which takes care of all of these.

http://marc.info/?l=linux-wireless&m=124767211929848&w=2

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
