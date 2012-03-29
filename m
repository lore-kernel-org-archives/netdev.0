From: Vinod Koul <vinod.koul@linux.intel.com>
Subject: Re: [PATCH linux-next] dmaengine: add context
	parameter fixups
Date: Thu, 29 Mar 2012 16:29:45 +0530
Message-ID: <1333018785.1820.48.camel@vkoul-udesk3>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
	<CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
	<1332740082.19804.15.camel@vkoul-udesk3>
	<20120326094200.GA3098@opensource.wolfsonmicro.com>
	<s5hwr64wx0p.wl%tiwai@suse.de>
	<20120328155106.GY3232@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, alsa-devel@alsa-project.org, samuel@sortiz.org,
	paul.gortmaker@windriver.com, Takashi Iwai <tiwai@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	linux-next@vger.kernel.org, dan.j.williams@intel.com,
	Fabio Estevam <festevam@gmail.com>, lrg@ti.com
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20120328155106.GY3232@opensource.wolfsonmicro.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-03-28 at 16:51 +0100, Mark Brown wrote:
> On Wed, Mar 28, 2012 at 05:44:22PM +0200, Takashi Iwai wrote:
> > Mark Brown wrote:
> 
> > > No, not yet - it was only sent after the merge window.  Quite why nobody
> > > managed to notice it before then I don't know.  It'll go to him soon, or
> > > at least to Takashi, but don't know if it'll make -rc1 or not.
> 
> > How is the situation now?
> 
> > FYI, I'm going to send a pull request to Linus tomorrow or on Friday.
> > If anything needed to be merged in rc1, it must be there in time.
> 
> It's in my tree, I didn't see an enormous rush to get it in TBH.
I should be sending the pull request for slave-dma to Linus this
evening.
Can you please include the fix I did in your tree in your pull request.


-- 
~Vinod
