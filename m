From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] small skbuff.[ch] tweaks
Date: Tue, 2 Sep 2003 02:10:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030902091059.GA53570@gaz.sfgoth.com>
References: <20030902081625.GA52298@gaz.sfgoth.com> <20030902105833.04778449.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20030902105833.04778449.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Both unlikely(!ptr) and likely(ptr) are not needed because gcc assumes this
> by default

Is there any disadvantage to stating it explicitly?

-Mitch
