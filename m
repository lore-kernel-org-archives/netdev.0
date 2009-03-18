From: "Lubomir Rintel" <lkundrak@v3.sk>
Subject: Re: e1000e 0000:00:19.0: DMA-API: device driver tries
 to free DMA memory it has not allocated [device address=0x0000000052ff084a]
 [size=90 bytes]
Date: Wed, 18 Mar 2009 08:54:31 -0400 (EDT)
Message-ID: <36697.89.102.207.186.1237380871.squirrel@mail.v3.sk>
References: <1237223130-26519-1-git-send-email-joerg.roedel@amd.com>
	<20090317120112.GP6159@amd.com> <20090318093847.GC5879@elte.hu>
	<20090318115615.GS6159@amd.com> <20090318120458.GA1601@elte.hu>
Reply-To: lkundrak@v3.sk
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Joerg Roedel <joerg.roedel@amd.com>,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090318120458.GA1601@elte.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, March 18, 2009 8:04 am, Ingo Molnar wrote:
>
> ( e1000e Cc:s added. A new debug feature, CONFIG_DMA_API_DEBUG=y,
>   has triggered the warning below in e1000_put_txbuf(). )

http://lkml.org/lkml/2009/3/2/318

-- 
Lubomir Rintel


------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
