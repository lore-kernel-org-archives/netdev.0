From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: wireless router performance differ with 2.4Ghz vs 5.0Ghz frequency
Date: Thu, 23 Aug 2012 20:34:44 +1000
Message-ID: <CAGRGNgWddAH3UyYq5T7iT+FuX8ajdGpP6rfjjCUkZZpiCoTmpQ@mail.gmail.com>
References: <CAF1ivSZ63Zr9STz3NnLV=ynRftMokG=ZGghd+cQu=HRUsiH+EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Lin Ming <mlin-H0MqCF3V8pkCalJqGWEchg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAF1ivSZ63Zr9STz3NnLV=ynRftMokG=ZGghd+cQu=HRUsiH+EA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Aug 23, 2012 at 2:50 PM, Lin Ming <mlin-H0MqCF3V8pkCalJqGWEchg@public.gmane.org> wrote:
> Hi list,
>
> I have a wireless router with 2 wireless cards: 2.4Ghz and 5.0Ghz frequency.
>
> The performance for 2.4Ghz is much worse than 5.0Ghz.
>
> Does the frequency affect performance so much?

There are a lot of factors:
- Amounts of other networks on the same channel
- Noise
- Signal strength
etc.

It's quite possible that there are less networks on 5GHz channels
where you are so there's less noise, stronger signal, and therefore
better performance. Most routers are still only 2.4GHz.

Thanks,

-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
