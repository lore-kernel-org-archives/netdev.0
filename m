From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: mvm: only send LEDS_CMD when the FW supports it
Date: Thu, 7 Sep 2017 09:13:00 -0700
Message-ID: <CA+55aFyeEwg7vd8FPHqG+4d7KbJ6ke4NDwhd+8y=_auRApyvmw@mail.gmail.com>
References: <CA+55aFxjHSW7v4Ttu7mGPkxdGpR-WtVoxDT5qtwxUC-Dge5a5A@mail.gmail.com>
 <20170907075152.4522-1-luca@coelho.fi> <877exan0nq.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
        Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Luca Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <877exan0nq.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 7, 2017 at 5:39 AM, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>
> Linus, do you want to apply this directly or should we take it via the
> normal route (wireless-drivers -> net)? If your prefer the latter when
> I'm planning to submit this to Dave in a day or two and expecting it to
> get to your tree in about a week, depending of course what is Dave's
> schedule.

Since we have a workaround for the problem, let's just go through the
regular channels. As long as I get the fix through David before the
merge window closes, I'm happy.

              Linus
