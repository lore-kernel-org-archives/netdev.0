From: Andi Kleen <ak@suse.de>
Subject: Re: Route cache performance under stress
Date: Fri, 23 May 2003 11:03:01 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030523110301.25b95026.ak@suse.de>
References: <1053602138.9475.34.camel@tux.rsn.bth.se>
	<20030522.180152.15252868.davem@redhat.com>
	<20030523102113.4fe38159.ak@suse.de>
	<20030523.012205.123984853.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030523.012205.123984853.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Fri, 23 May 2003 01:22:05 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:


> I believe you.
> 
> Then what does that comment above it mean? :-)

I guess it refers to the implementation, not the code.

For pure 2^n you could implement it much more efficiently using ffz()
(not that it really matters of course, most orders are 0)

-Andi

