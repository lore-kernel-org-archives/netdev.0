From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 27 Jul 2003 15:12:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030727151234.6e2aa57e.davem@redhat.com>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcelo@conectiva.com.br, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bas Bloemsaat <bloemsaa@xs4all.nl>
In-Reply-To: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 27 Jul 2003 22:52:48 +0200 (CEST)
Bas Bloemsaat <bloemsaa@xs4all.nl> wrote:

> I think this is unwanted behaviour.

Not a bug.  This behavior is on purpose.

Use source based routes if you want to control how ARP
responses behave in this way.

This is becomming a FAQ.
