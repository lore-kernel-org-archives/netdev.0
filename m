From: Andrew Morton <akpm@digeo.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 16:25:27 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030627162527.714091ce.akpm@digeo.com>
References: <20030626.224739.88478624.davem@redhat.com>
	<21740000.1056724453@[10.10.2.4]>
	<Pine.LNX.4.55.0306270749020.4137@bigblue.dev.mcafeelabs.com>
	<20030627.143738.41641928.davem@redhat.com>
	<Pine.LNX.4.55.0306271454490.4457@bigblue.dev.mcafeelabs.com>
	<20030627213153.GR501@phunnypharm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidel@xmailserver.org, davem@redhat.com, mbligh@aracnet.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Collins <bcollins@debian.org>
In-Reply-To: <20030627213153.GR501@phunnypharm.org>
List-Id: netdev.vger.kernel.org

Ben Collins <bcollins@debian.org> wrote:
>
>  I'm with Dave on this one.

I also.  The bug database tries to convert the traditional many<->many
debugging process into a one<->one process.  This surely results in a
lower cleanup rate.

It's irritating replying to a bugzilla entry when you _know_ that you're
cutting other interested parties out of the loop.

And mailing lists tend to be self-correcting:

- The once-off bugs due to broken hardware get filtered away.

- The bugs which simply get magically fixed when someone repaired some
  unrelated part of the kernel get filtered out.

- The bugs which are affecting people the most get reported the most.

- Lots of other people can chip in with potentially useful info.


It is nice to have a record.  But bugzilla is not a comfortable or
productive environment within which to drill down into and fix problems.

