From: "David S. Miller" <davem@redhat.com>
Subject: Re: GRE tunnel keepalive support?
Date: Tue, 9 Dec 2003 22:33:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209223321.29861dc8.davem@redhat.com>
References: <20031210064420.A22481@homebase.cluenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Roesen <dr@cluenet.de>
In-Reply-To: <20031210064420.A22481@homebase.cluenet.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 06:44:20 +0100
Daniel Roesen <dr@cluenet.de> wrote:

> is anybody aware of anyone implementing keepalives for GRE tunnels?
> I don't want to duplicate efforts...
> 
> http://www.cisco.com/en/US/products/sw/iosswrel/ps1838/
> products_feature_guide09186a0080134a36.html

Not to my knowledge.  It looks like a rather simple mechanism,
and should be easy to code up.  Feel free.
