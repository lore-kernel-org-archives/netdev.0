From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH net-next] net: ppp: don't call sk_chk_filter twice
Date: Sun, 13 Jul 2014 15:06:34 +0200
Message-ID: <53C2845A.3080009@kristov.de>
References: <53BF8DEC.4000307@kristov.de> <CAADnVQLQR9fYVGfxfnwpirXt4CwBUzr36tJL+aEoo0err7cppw@mail.gmail.com> <20140712231126.103531fxfrk9sola@kristov.noip.me> <53C25EF9.7030909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <53C25EF9.7030909@redhat.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Am 13.07.2014 12:27, schrieb Daniel Borkmann:

> I think the patch makes sense, and you could submit it against net tree
> (so 'PATCH net' in subject) with a slightly different commit log at the
> beginning, but the rest could stay explaining that that's the case for
> 3.15. By that, this could then be picked up into the net tree and thus
> Dave can queue it for stable inclusion. If you need any help, let me know.

I have just resubmitted the patch and hope I did it better this time.
Please let me know whether the commit log is correct now.


Thank you,

Christoph Schulz

