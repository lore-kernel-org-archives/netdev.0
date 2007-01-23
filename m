From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Tue, 23 Jan 2007 14:27:07 -0500
Message-ID: <45B6618B.7000803@hp.com>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <45B504DC.8030107@kolumbus.fi> <20070122194548.GE21059@hmsreliant.homelinux.net> <45B51DC3.1010303@hp.com> <20070123183607.GA582@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:51873 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933112AbXAWT1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 14:27:10 -0500
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20070123183607.GA582@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil

Neil Horman wrote:
> +				/*
> +				 * This is not a dad solicitation, meaning we may
> +				 * need to respond to it, if we are 
> +				 * an optimistic node, go ahead, otherwise 
> +				 * ignore it

Nit.  Can you rephrase the comment just a bit.  It seems a bit of a run-on sentence...

The other comment from Yoshifuji-san still apply.

Thanks
-vlad

