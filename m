From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting bad/custom CRC
Date: Tue, 25 Nov 2003 15:42:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125154249.B1107@sygehus.dk>
References: <3FC2931B.3070903@candelatech.com> <20031124152933.1420f6cf.davem@redhat.com> <3FC298C9.8080302@candelatech.com> <20031124173330.096c0751.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031124173330.096c0751.davem@redhat.com>; from davem@redhat.com on Mon, Nov 24, 2003 at 05:33:30PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2003 at 05:33:30PM -0800, David S. Miller wrote:
> On Mon, 24 Nov 2003 15:48:25 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> > Btw, it's impossible (afaik) to see the CRC errors generically w/out
> > accessing netlink (which I assume works, but have never actually tried), ie

> The netlink thing does work, trust me :)
> You could argue that 'ip -s link' should print this out, and I'd
> agree with you on that.

Give it another -s, i.e. 'ip -s -s link', and it does. :-)

-- 
Regards,
Rask Ingemann Lambertsen
