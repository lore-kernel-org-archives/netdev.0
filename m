From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Tue, 13 Dec 2016 14:06:25 +0530
Message-ID: <CA+sbYW0NuFY9e8n+m7HtPbEW31n+bWEcF-t81jXR9idj4AjWLw@mail.gmail.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
 <23e26353-4317-2836-9f94-d1fc3274a770@redhat.com> <CAJ3xEMh98kC1KXGf7uHKD-H91f_NiZXaz-3yTtwQ2s-D7rYqMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ3xEMh98kC1KXGf7uHKD-H91f_NiZXaz-3yTtwQ2s-D7rYqMQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2016 at 1:29 PM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> I made some quick on-the-surface static checkers etc rub on the new
> driver (Doug, I used
> the bits in your github bnxt_re branch), there are bunch (tons...) of
> smatch [1] and sparse [2]
> complaints along with few checkpatch [3] things too.  So... addressing
> them before this goes upstream?

Thank you for pointing it out. I will include this cleanup also as a
part of my v3 series.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
