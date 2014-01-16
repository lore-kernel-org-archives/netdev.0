From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 0/2] net: mvneta: simple cleanups
Date: Thu, 16 Jan 2014 07:16:15 +0100
Message-ID: <20140116061615.GB15597@1wt.eu>
References: <cover.1389742334.git.arno@natisbad.org>
 <20140115.154122.1485420525760591929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
 arno@natisbad.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20140115.154122.1485420525760591929.davem@davemloft.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, Jan 15, 2014 at 03:41:22PM -0800, David Miller wrote:
> From: Arnaud Ebalard <arno@natisbad.org>
> Date: Wed, 15 Jan 2014 00:45:31 +0100
> 
> > 
> > Those two patches are intended for net-next. They apply on top of
> > performance improvements patches from Willy for mvneta driver.
> > They provide some simple cleanups for unused variables, function
> > params or return values.
> > 
> > Arnaud Ebalard (2):
> >   net: mvneta: mvneta_tx_done_gbe() cleanups
> >   net: mvneta: make mvneta_txq_done() return void
> 
> These patches do not apply to net-next, please respin.

They depend on the two series I sent, I verified that they apply well
once these two series are applied to net-next.

Would you prefer that we resend a complete series with all the patches
at once ?

Thanks,
Willy
