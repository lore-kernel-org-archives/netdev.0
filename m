From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Mon, 29 Nov 2004 20:09:43 +0100
Message-ID: <20041129190943.GB21164@xi.wantstofly.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com> <20041127200030.GD27762@xi.wantstofly.org> <1101732267.14930.75.camel@verza.polito.it> <20041129151940.GA19184@xi.wantstofly.org> <1101749533.17091.3.camel@verza.polito.it> <20041129190808.GA21164@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Mellia <mellia@prezzemolo.polito.it>
Content-Disposition: inline
In-Reply-To: <20041129190808.GA21164@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2004 at 08:08:08PM +0100, Lennert Buytenhek wrote:

> packets and then writing the values 0, 1, 2, 3 ... n-1 to the TXD register
								^^^
That should be TDT.


--L
