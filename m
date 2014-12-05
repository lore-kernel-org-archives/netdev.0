From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: Remove inline from static function
 definitions
Date: Thu, 04 Dec 2014 17:43:19 -0800
Message-ID: <1417743799.2721.31.camel@perches.com>
References: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
	 <1417734048.2721.22.camel@perches.com>
	 <1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQ+3jiYOYReRLPUsFeG1p66ezo-TXBLX3BGQQh7V8QX0tQ@mail.gmail.com>
	 <1417740382.22424.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1417741284.2721.26.camel@perches.com>
	 <CAADnVQ+5T3MDiC7RwVwdyu2PEhGy0VOrp7=LWeENrX_USXevnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0131.hostedemail.com ([216.40.44.131]:50850 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932975AbaLEBnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 20:43:24 -0500
In-Reply-To: <CAADnVQ+5T3MDiC7RwVwdyu2PEhGy0VOrp7=LWeENrX_USXevnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-12-04 at 17:21 -0800, Alexei Starovoitov wrote:
> Joe, please mention dependencies next time.

No real need here.
It's in the same thread.
