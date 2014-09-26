From: Nicholas Krause <yocto6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: FIXMEs in rt2800lib.c
Date: Fri, 26 Sep 2014 09:32:18 -0400
Message-ID: <CAAxn8J=gKVdNt3+Ayx-XdEki7V8sg-M7C=kK7sGADBO3L-PTQw@mail.gmail.com>
References: <5424566B.6000206@gmail.com>
	<20140926122207.GA27809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ivo Van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"julia.lawall-L2FTfq7BK8M@public.gmane.org oneukum-l3A5Bk7waGM@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140926122207.GA27809-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 8:22 AM, Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Sep 25, 2014 at 01:52:43PM -0400, nick wrote:
>> I seem to be hitting to fix mes in the file I listed in the subject. Would someone tell me if it's Ok to remove
>> the lines that over write certain registers.
>
> No, as long you prove that they are not needed.
>
> Stanislaw
Sure Stanislw,
I will remove the lines as needed and send it a patch.
Nick
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
