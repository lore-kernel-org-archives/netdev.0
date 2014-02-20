From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Thu, 20 Feb 2014 01:58:33 +0100
Message-ID: <20140220005833.GF1179@order.stressinduktion.org>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com> <1392433180-16052-3-git-send-email-mcgrof@do-not-panic.com> <1392668638.21106.5.camel@dcbw.local> <CAB=NE6XGBp1RwO63W0ac6tTr9JcRM9TB9sap4pa+8PMWwjxu6g@mail.gmail.com> <1392828325.21976.6.camel@dcbw.local> <CAB=NE6VpUqwNNY4pgbS6du2VsZ6dH0TzQYXmiw6GGN-EiOsV6g@mail.gmail.com> <1392857777.22693.14.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392857777.22693.14.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 19, 2014 at 06:56:17PM -0600, Dan Williams wrote:
> Note that there isn't yet a disable_ipv4 knob though, I was
> perhaps-too-subtly trying to get you to send a patch for it, since I can
> use it too :)

Do you plan to implement
<http://datatracker.ietf.org/doc/draft-ietf-sunset4-noipv4/>?

;)
