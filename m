From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Mon, 28 Nov 2011 21:55:57 +0100
Message-ID: <CAFLxGvwmsQOcOL2oO33_dvLgsA9Gsdtp5u=nCZFPV-ihNdCm3g@mail.gmail.com>
References: <4ED3C174.9030302@earthlink.net>
	<CAF9AA63.1622%ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ulrich Weber <Ulrich.Weber@sophos.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAF9AA63.1622%ulrich.weber@sophos.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2011 at 9:25 PM, Ulrich Weber <Ulrich.Weber@sophos.com> wrote:
> IPv6->IPv4:
>
> http://ecdysis.viagenie.ca

Is this solution stable?
The last time I've tested it it had no SMP locking at all...

-- 
Thanks,
//richard
