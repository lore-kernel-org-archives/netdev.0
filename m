From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM] some misc sk-related fixups for atm
Date: Tue, 15 Jul 2003 21:53:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715215300.1927dbac.davem@redhat.com>
References: <200307151254.h6FCshsG028747@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200307151254.h6FCshsG028747@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 08:52:15 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> this set does away with a few redundant bits in the struct atm_vcc,
> in particular .reply and .svc_callback.  WAITING becomes a flag 
> instead of overloading sk_err.  it also changes the wake_up's to
> the appropriate sk event.

Looks good, applied.

Thanks Chas.
