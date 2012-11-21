From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 198/493] ethernet: remove use of __devinit
Date: Wed, 21 Nov 2012 11:55:44 +0000
Message-ID: <20121121115544.GG3290@n2100.arm.linux.org.uk>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
 <1353349642-3677-198-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Chris Snook <chris.snook@gmail.com>,
 Samuel Chessman <chessman@tux.org>, David Dillow <dave@thedillows.org>,
 Jaroslav Kysela <perex@perex.cz>, Daniele Venzano <venza@brownhat.org>,
 Pantelis Antoniou <pantelis.antoniou@gmail.com>,
 Stephen Hemminger <shemminger@vyatta.com>, John Linn <John.Linn@xilinx.com>,
 e1000-devel@lists.sourceforge.net, Guo-Fu Tseng <cooldavid@cooldavid.org>,
 linux-acenic@sunsite.dk, cbe-oss-dev@lists.ozlabs.org,
 Francois Romieu <romieu@fr.zoreil.com>,
 Steve Glendinning <steve.glendinning@shawell.net>,
 Jes Sorensen <jes@trained-monkey.org>, Jay Cliburn <jcliburn@gmail.com>,
 Realtek linux nic maintainers <nic_swsd@realtek.com>,
 Grant Grundler <grundler@parisc-linux.org>, Wan ZongShun <mcuos.com@gmail.com>,
 Anirudha Sarangi <anirudh@xilinx.com>, linuxppc-dev@lists.ozlabs.org,
 Don Fry <pcnet32@frontier.com>,
 Thadeu Lima de Sou
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1353349642-3677-198-git-send-email-wfp5p@virginia.edu>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2012 at 01:22:27PM -0500, Bill Pemberton wrote:
>  drivers/net/ethernet/8390/etherh.c                 |  4 +-
>  drivers/net/ethernet/amd/am79c961a.c               |  2 +-
>  drivers/net/ethernet/i825xx/ether1.c               |  8 +-
>  drivers/net/ethernet/seeq/ether3.c                 | 10 +--

For these four,

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
