From: "David S. Miller" <davem@redhat.com>
Subject: Re: O/M flags for 2.4.22 (was "Re: O/M flags against 2.6.0-test1")
Date: Fri, 12 Sep 2003 17:19:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912171921.37cab171.davem@redhat.com>
References: <20030911192507.0b3f2633.davem@redhat.com>
	<Pine.LNX.4.44.0309121537430.1445-100000@linux-udp12861866uds>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
   krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0309121537430.1445-100000@linux-udp12861866uds>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003 15:45:15 -0700 (PDT)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> > I'm happy to apply a 2.4.x version as well.
> 
> Patch against 2.4.22 follows.

I applied the 2.6.x version, but this 2.4.x version does
not apply cleanly, there are a bunch of rejects.

That's not surprising since there's been, as there always is, several
networking updates in 2.4.x since 2.4.22 already which cause conflicts
with your patch.

Please always, and I mean always, create patches against the most
recent possible version of 2.4.x or 2.6.x.  We'll never have
to go back and forth like this if you do that.
