From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: The ultimate TOE design
Date: Fri, 24 Sep 2004 15:07:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040924130738.GB24093@xi.wantstofly.org>
References: <20040915142926.7bc456a4.davem@davemloft.net> <200409152329.i8FNTsqG025184@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David S. Miller'" <davem@davemloft.net>,
	'Jeff Garzik' <jgarzik@pobox.com>, alan@lxorguk.ukuu.org.uk,
	paul@clubi.ie, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268729AbUIXNHk@vger.kernel.org>
To: Leonid Grossman <leonid.grossman@s2io.com>
Content-Disposition: inline
In-Reply-To: <200409152329.i8FNTsqG025184@guinness.s2io.com>
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 04:29:45PM -0700, Leonid Grossman wrote:

> And at 10GbE, embedded CPUs just don't cut it - it has to be custom ASIC
> (granted, with some means to simplify debugging and reduce the risk of hw
> bugs and TCP changes).

Intel's IXP2800 can do 10GbE.

http://www.intel.com/design/network/products/npfamily/ixp2800.htm


--L
