From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 27 Jul 2003 16:46:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030727164649.517b2b88.davem@redhat.com>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
	<200307280140470646.1078EC67@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Carlos Velasco" <carlosev@newipnet.com>
In-Reply-To: <200307280140470646.1078EC67@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Jul 2003 01:40:47 +0200
"Carlos Velasco" <carlosev@newipnet.com> wrote:

> I stepped into the same problems you have reported here.

No, your problem was completely different.

> There's a feature to do linux to behave like other OS and systems, called "hidden".

WRONG!  People please stop this misinformation already.

Bas's problem can be solved by him giving a "preferred source"
to each of his IPV4 routes and setting the "arpfilter" sysctl
variable for his devices to "1".

This particular case has been discussed to death in the past
and I really recommend people read up there before dragging this
out further.
