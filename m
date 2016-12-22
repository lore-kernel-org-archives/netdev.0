From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/3] NFC: trf7970a: add device tree option for 27MHz clock
Date: Thu, 22 Dec 2016 12:48:27 -0600
Message-ID: <CAL_JsqL4TMDaMQZM3h5gRBEiAa7-ApUWj4GgS_BPG6qpoLxv6g@mail.gmail.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
 <20161219223111.itu77g7wsqtj6cvs@rob-hp-laptop> <CAO7Z3WKmEbJCN_=srxTVKXvtz84vHGi41RS+9T7fmkmhRB6nEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mark Greer <mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org>,
        Justin Bronder <justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
To: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAO7Z3WKmEbJCN_=srxTVKXvtz84vHGi41RS+9T7fmkmhRB6nEw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 5:23 PM, Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org> wrote:
> I can make that change, however, I worry that it may be a bit
> misleading, since there are only two supported clock frequencies, but
> a number like that to me implies that it could be set to any number
> you want.   I'm new at this, and so I'll go ahead and change it as you
> request, but I'd like to hear your thoughts on my concern.

Then the binding doc just needs to state what are the 2 valid frequencies.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
