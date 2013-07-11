From: "Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>
Subject: Re: backports based on next-20130618
Date: Thu, 11 Jul 2013 00:34:10 -0700
Message-ID: <CAB=NE6Xv91ma2KyXkEUUjFwH7nk4vdXfX8A6i9KmvUvYKn_tgg@mail.gmail.com>
References: <CAB=NE6W6oa1Oa9O_s7B_4qKHdEz6S3DhVyvtpzP78XqRM_xk8A@mail.gmail.com>
 <CAB=NE6Vf0BO_d=qPrpU=mYAv6DeRPanQqV6BshkVjJ0Tf4ponw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <backports-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6Vf0BO_d=qPrpU=mYAv6DeRPanQqV6BshkVjJ0Tf4ponw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 1, 2013 at 2:39 PM, Luis R. Rodriguez
<mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org> wrote:
> On Mon, Jul 1, 2013 at 2:25 PM, Luis R. Rodriguez
> <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org> wrote:
>> A new backports release has been made based on next-20130618, this has
>> the new upstream alx driver, and the ath10k driver.
>>
>> https://www.kernel.org/pub/linux/kernel/projects/backports/2013/06/18/backports-20130618.tar.bz2
>
> Sorry it just has alx, ath10k requires a small patch that I think
> someone has sitting somewhere, next release.

Nevermind, it was in already and in fact compiled fine as part of this release.

  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/mac.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/debug.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/core.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/htc.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/htt.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/htt_rx.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/htt_tx.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/txrx.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/wmi.o
  CC [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/bmi.o
  LD [M]  /home/mcgrof/tmp/poo/backports-20130618/drivers/net/wireless/ath/ath10k/ath10k_core.o

 Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
