From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] isdn/gigaset: Convert timers to use timer_setup()
Date: Thu, 5 Oct 2017 12:17:42 -0700
Message-ID: <CAGXu5jKbMvCcAkYSHF9n9t2+Q+JBP+aFV6Kz0PO4KD49uDDdaA@mail.gmail.com>
References: <20171005005212.GA23556@beast> <1507190336.2167.5.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net,
        Network Development <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        LKML <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507190336.2167.5.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 5, 2017 at 12:58 AM, Paul Bolle <pebolle@tiscali.nl> wrote:
> Hi Kees,
>
> On Wed, 2017-10-04 at 17:52 -0700, Kees Cook wrote:
>> Also uses kzmalloc to replace open-coded field assignments to NULL and zero.
>
> If I'm allowed to whine (chances that I'm allowed to do that are not so great
> as Dave tends to apply gigaset patches before I even have a chance to look at
> them properly!): I'd prefer it if that was done separately in a preceding
> patch. Would that bother you?

Sure, that's fine, I'll split it and re-send.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security
