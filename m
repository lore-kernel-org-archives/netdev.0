From: "David S. Miller" <davem@redhat.com>
Subject: Re: PATCH idea - netlink and link changes
Date: Sat, 12 Oct 2002 02:11:09 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021012.021109.26965691.davem@redhat.com>
References: <3DA7035F.5080101@sun.com>
	<3DA7EA1B.3D0430F@isg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thockin@sun.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: srompf@isg.de
In-Reply-To: <3DA7EA1B.3D0430F@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stefan Rompf <srompf@isg.de>
   Date: Sat, 12 Oct 2002 11:23:39 +0200
   
   IMHO we should merge the patches, taking your one workqueue per device
   approach and my usage of IFF_RUNNING as a mirror bit. What do other
   netdev people think?

I'm waiting for Jamal to catch up on his email and comment
on this stuff, he had very clear ideas about what should
be happening here.
