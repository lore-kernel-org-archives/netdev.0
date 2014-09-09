From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: iwlwifi no authentication with AP - Re: pull request: wireless-next
 2014-09-08
Date: Tue, 09 Sep 2014 22:23:44 +0200
Message-ID: <540F61D0.9000704@hartkopp.net>
References: <20140908191630.GB29412@tuxdriver.com>	<540F5927.7000306@hartkopp.net> <CANUX_P3n0v1SzfbYuaAsE4TY7Hz_wo2Fb9SmHVNyFOC9hDhwdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANUX_P3n0v1SzfbYuaAsE4TY7Hz_wo2Fb9SmHVNyFOC9hDhwdg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09.09.2014 22:02, Emmanuel Grumbach wrote:
> On Tue, Sep 9, 2014 at 10:46 PM, Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org> wrote:
>> Hello John, all,
>>
>> on my i7 Laptop with iwlwifi the latest net-next does not connect to my access point:
> 
> Are you sure this wasn't the case before?

Indeed I moved to net-next right today - as I also had the LED lockdep splat
on 3.17-rcX with X < 4.

So it can be that this issue was already introduced at the beginning of this
net-next cycle. Don't know, sorry. The latest 3.17-rc4 from Linus' tree works
fine. I'm running a Debian unstable here (in both cases).

> Can you bisect?

Not really. I'm running the kernel on my bare machine - and I just wanted to
go to bed right now ...

So I will be able to test patches tomorrow morning again.

Tnx for your fast feedback,
Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
