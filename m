From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patches] invalid nh.raw use after free
Date: Wed, 16 Jul 2003 00:17:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716001724.7874a51a.davem@redhat.com>
References: <20030715191709.1e0c6427.davem@redhat.com>
	<Pine.LNX.4.44.0307161007070.1921-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0307161007070.1921-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 10:09:02 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> On Tue, 15 Jul 2003, David S. Miller wrote:
> 
> > Good catch, I'll apply this.
> 
> 	Please, apply also to 2.2

Please forward to Alan for that, I don't have the
resources to maintain 2.2.x along with all the other
stuff.
