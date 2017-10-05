From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] isdn/gigaset: Convert timers to use timer_setup()
Date: Thu, 05 Oct 2017 09:58:56 +0200
Message-ID: <1507190336.2167.5.camel@tiscali.nl>
References: <20171005005212.GA23556@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005005212.GA23556@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kees,

On Wed, 2017-10-04 at 17:52 -0700, Kees Cook wrote:
> Also uses kzmalloc to replace open-coded field assignments to NULL and zero.

If I'm allowed to whine (chances that I'm allowed to do that are not so great
as Dave tends to apply gigaset patches before I even have a chance to look at
them properly!): I'd prefer it if that was done separately in a preceding
patch. Would that bother you? 

Thanks,


Paul Bolle
