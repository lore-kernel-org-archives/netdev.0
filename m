From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 4/4] xen-netback: skip IPv4 and IPv6 interfaces
Date: Tue, 18 Feb 2014 12:16:36 -0800
Message-ID: <CAB=NE6WwPfPi-8Yudxs4-OA2LPOjo8-XxUiVbtu6=BQ8FhEEOA@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
 <1392433180-16052-5-git-send-email-mcgrof@do-not-panic.com> <53021E87.6020607@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, kvm@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53021E87.6020607@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 17, 2014 at 6:36 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> There is a valid scenario to put IP addresses on the backend VIFs:
>
> http://wiki.xen.org/wiki/Xen_Networking#Routing

This is useful thanks!

> Also, the backend is not necessarily Dom0, you can connect two guests with
> backend/frontend pairs.

Can you elaborate a bit more on this type of setup?

  Luis
