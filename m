From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Mon, 18 Jul 2011 16:45:47 -0700
Message-ID: <CAL1RGDW0gyQZAqR4XfCJTLrcmCD+h836vG=N1J_Emzhi8YEYHw@mail.gmail.com>
References: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com>
 <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E@ch.ibm.com>
 <BANLkTi=2woNzF=GL3cT3NB_hye5JHfodMA@mail.gmail.com> <BANLkTi=L057TZug2=nrFZTYdNoHLMvmBRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=L057TZug2=nrFZTYdNoHLMvmBRA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> There seems to be disagreement about whether to return 0, -ENOSYS or
> -EOPNOTSUPP for not supported functionality. Does the patch below make sense ?
> Note: I don't have all the hardware necessary to test the patch below.

This makes sense to me, so I went ahead and applied it for 3.1 (minus
the siw part, of course).
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
