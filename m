From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting
 bad/custom CRC
Date: Tue, 25 Nov 2003 06:45:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125064533.44400654.davem@redhat.com>
References: <3FC2931B.3070903@candelatech.com>
	<20031124152933.1420f6cf.davem@redhat.com>
	<3FC298C9.8080302@candelatech.com>
	<20031124173330.096c0751.davem@redhat.com>
	<20031125154249.B1107@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031125154249.B1107@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Nov 2003 15:42:49 +0100
Rask Ingemann Lambertsen <rask@sygehus.dk> wrote:

> On Mon, Nov 24, 2003 at 05:33:30PM -0800, David S. Miller wrote:
> > The netlink thing does work, trust me :)
> > You could argue that 'ip -s link' should print this out, and I'd
> > agree with you on that.
> 
> Give it another -s, i.e. 'ip -s -s link', and it does. :-)

I certainly learned something today :)
