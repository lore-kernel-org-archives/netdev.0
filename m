From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 05/13] remove last_rx update from loopback device
Date: Tue, 15 Mar 2005 17:17:38 -0800
Message-ID: <20050315171738.29ad1eed.davem@davemloft.net>
References: <200503152222.j2FMMbhG016805@shell0.pdx.osdl.net>
	<423764A3.8030201@pobox.com>
	<20050315150809.579c5e85.akpm@osdl.org>
	<20050315165345.735573de.davem@davemloft.net>
	<42378617.3080600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com, christoph@graphe.net,
        nirajk@calsoftinc.com, christoph@lameter.com, Shai@Scalex86.org
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42378617.3080600@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 17:04:23 -0800
Rick Jones <rick.jones2@hp.com> wrote:

> Perhaps that is a driver-ing (since punning drive/driver seems to be the order N 
> squared of the day) force behind the changes?

Every time the SGI guys with the 512 cpu machine find some shared
memory reference they think they can legitimately remove, they
try to do so.
