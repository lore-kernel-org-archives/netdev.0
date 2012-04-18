From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 13:31:02 -0400 (EDT)
Message-ID: <20120418.133102.1711079292327461659.davem@davemloft.net>
References: <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
	<20120418.001650.1042781402985153056.davem@davemloft.net>
	<CADZpyixnQMM5WFWLyvEQ=D-tvrqFGe4PC5WdUzxVtdL96NODJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CADZpyixnQMM5WFWLyvEQ=D-tvrqFGe4PC5WdUzxVtdL96NODJQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>
Date: Wed, 18 Apr 2012 08:57:58 -0400

> In summary your opinion is that the API has and always will allow up
> to 108 chars to be used in sun_path?

Yes.

> In which case I will talk to the Austin group to get a good example
> added to POSIX showing safe usage.

Why would you add language to POSIX for Linux specific behavior?
Just curious :-)
