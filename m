From: Daniel Roesen <dr@cluenet.de>
Subject: Re: GRE tunnel keepalive support?
Date: Wed, 10 Dec 2003 07:52:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210075258.A23221@homebase.cluenet.de>
References: <20031210064420.A22481@homebase.cluenet.de> <20031209223321.29861dc8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031209223321.29861dc8.davem@redhat.com>; from davem@redhat.com on Tue, Dec 09, 2003 at 10:33:21PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 09, 2003 at 10:33:21PM -0800, David S. Miller wrote:
> > is anybody aware of anyone implementing keepalives for GRE tunnels?
> > I don't want to duplicate efforts...
> > 
> > http://www.cisco.com/en/US/products/sw/iosswrel/ps1838/
> > products_feature_guide09186a0080134a36.html
> 
> Not to my knowledge.  It looks like a rather simple mechanism,
> and should be easy to code up.  Feel free.

OK, anything else than "easy" would be out of scope anyway, given
significant time constraints and never did any kernel work at all
(except some micropatches). Given that there is no documentation
whatsoever, I will have to do some reverse engineering though.


Best regards,
Daniel
