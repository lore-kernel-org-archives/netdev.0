From: James Morris <jmorris@redhat.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 10:38:46 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0412171038140.14229-100000@thoron.boston.redhat.com>
References: <20041217151031.GA27170@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bryan Fulton <bryan@coverity.com>, <linux-kernel@vger.kernel.org>,
        <netdev@oss.sgi.com>, <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20041217151031.GA27170@atrey.karlin.mff.cuni.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2004, Pavel Machek wrote:

> Hi!
> 
> > This at least needs CAP_NET_ADMIN.
> 
> Hmm, but that means that CAP_NET_ADMIN implies all other capabilities,
> unless you fix this.

I'm not saying it doesn't need to be fixed, but that it is not exploitable 
by unprivileged users.


- James
-- 
James Morris
<jmorris@redhat.com>
