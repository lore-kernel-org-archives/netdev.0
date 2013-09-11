From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: fix possible format string flaw
Date: Wed, 11 Sep 2013 08:18:13 +0100
Message-ID: <1378883893.3057.60.camel@dagon.hellion.org.uk>
References: <20130911043911.GA17237@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130911043911.GA17237@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-09-10 at 21:39 -0700, Kees Cook wrote:
> This makes sure a format string cannot accidentally leak into the
> kthread_run() call.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Thanks.

Ian.
