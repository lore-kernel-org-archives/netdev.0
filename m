From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 08:22:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819082227.5ef3b7ed.davem@redhat.com>
References: <Pine.LNX.3.96.1030818171100.2101C-100000@gatekeeper.tmr.com>
	<3F41979C.3070408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidsen@tmr.com, willy@w.ods.org, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, bloemsaa@xs4all.nl,
   marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F41979C.3070408@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 20:21:00 -0700
Ben Greear <greearb@candelatech.com> wrote:

> I never did hear a response to my comment that this
> was inadequate in this age of vlans...

Just define a rtnetlink attribute to extend the ID
number, that's all.  It's not hard work and it eliminates
the 8-bit limit.
