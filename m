From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: Documentation: Fix default value
 tcp_limit_output_bytes
Date: Wed, 11 Nov 2015 11:57:24 -0500 (EST)
Message-ID: <20151111.115724.1455490917002925021.davem@davemloft.net>
References: <1447077529-9200-1-git-send-email-niklass@axis.com>
	<20151111095002.2311dada@xps>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niklas.cassel@axis.com, edumazet@google.com, tom@herbertland.com,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	niklass@axis.com, netdev@vger.kernel.org
To: corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20151111095002.2311dada@xps>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jonathan Corbet <corbet@lwn.net>
Date: Wed, 11 Nov 2015 09:50:02 -0700

> On Mon, 9 Nov 2015 14:58:49 +0100
> Niklas Cassel <niklas.cassel@axis.com> wrote:
> 
>> Commit c39c4c6abb89 ("tcp: double default TSQ output bytes limit")
>> updated default value for tcp_limit_output_bytes
> 
> I left this last time because Dave usually likes to pick up networking
> docs patches himself.  This wasn't sent to netdev, though, so that's
> unlikely to happen.  I've gone ahead and applied it, since it seems
> clearly correct.

I already took this into my tree as per:

	http://marc.info/?l=linux-netdev&m=144708947814679&w=2

and patchwork entry:

	http://patchwork.ozlabs.org/patch/541786/

and since Linus pulled my tree in earlier today it's now in
his tree as well.

Thanks.
