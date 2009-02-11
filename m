From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Wed, 11 Feb 2009 21:19:08 +0100
Message-ID: <20090211201908.GA25398@rere.qmqm.pl>
References: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757632AbZBKUTY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0902111107480.15665@blackhole.kfki.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Feb 11, 2009 at 11:19:20AM +0100, Jozsef Kadlecsik wrote:
>  /* The golden ration: an arbitrary value */
> -#define JHASH_GOLDEN_RATIO	0x9e3779b9
> +#define JHASH_GOLDEN_RATIO	0xdeadbeef

I have a stupid question: if this is arbitrary value, then why not
just get rid of it (IOW use zero as it's used in addition)?

Best Regards,
Micha=B3 Miros=B3aw
