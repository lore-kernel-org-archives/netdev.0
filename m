From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 15:13:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627.151338.21924648.davem@redhat.com>
References: <Pine.LNX.4.55.0306271454490.4457@bigblue.dev.mcafeelabs.com>
	<20030627.150248.08328103.davem@redhat.com>
	<Pine.LNX.4.55.0306271509540.4457@bigblue.dev.mcafeelabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbligh@aracnet.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidel@xmailserver.org
In-Reply-To: <Pine.LNX.4.55.0306271509540.4457@bigblue.dev.mcafeelabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Davide Libenzi <davidel@xmailserver.org>
   Date: Fri, 27 Jun 2003 15:11:53 -0700 (PDT)
   
   Is a bug report more useful for the user of a "system" or for the
   "system" itself ?

You can ask the same question about a patch, and my answer
is the same, "it depends upon the bug/patch and whether
the people it affects actually care about it".

What's truly "useful" for the "system" are things that allow
the people that maintain it to SCALE.  Lossless bug and patch
databases that force me to look at each and every item do not scale.

What you don't understand is that I, and most of the people who help
me, do this because I and they want to.  So as soon as things get
introduced that make us less "want" to do this you can be sure
contributions will slump slowly but surely to nothing.
