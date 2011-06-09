From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Thu, 9 Jun 2011 15:18:39 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F3820B85E7@AUSP01VMBX24.collaborationhost.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
	<20110605083445.GT16318@ibawizard.net> <20110605085948.GB16018@acer>
	<20110605.140801.1144137337172959622.davem@davemloft.net>
	<20110606172607.GB3082@acer>
	<ADE657CA350FB648AAC2C43247A983F001F381FC56CE@AUSP01VMBX24.collaborationhost.net>
	<20110609195052.GB2857@acer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kernel@wantstofly.org" <kernel@wantstofly.org>,
	"rmallon@gmail.com" <rmallon@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"florian@openwrt.org" <florian@openwrt.org>,
	"ynezz@true.cz" <ynezz@true.cz>, David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Mika Westerberg <mika.westerberg@iki.fi>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20110609195052.GB2857@acer>
Content-Language: en-US
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

On Thursday, June 09, 2011 12:51 PM, Mika Westerberg wrote:
> On Mon, Jun 06, 2011 at 12:48:19PM -0500, H Hartley Sweeten wrote:
>> If Lennert is no longer maintaining the this driver we really need someone to
>> step up and handle it.
>> 
>> I have no problem doing it but I really don't have a good grasp on the driver
>> or the whole network subsystem.
>> 
>> If Lennert is willing to hand it over, I have no problem being listed as a
>> co-maintainer along with either yourself of Ryan.  Between the two (or three)
>> of us we should be able to handle it.
>
> Hartley,
>
> Can you take maintainership of this driver? Since you already maintain most of
> the ep93xx core stuff I think that you are the right person for the job. If
> you need any assistance I believe me and Ryan can help you out.
>
> We have now few patches queued:
>	- this series from me to fix the DMA API violations
>	- phylib patches from Florian Fainelli
>
> It would be great to get those in someday :-)

Hmm.. Ok, fine ;-)

I just submitted a patch to lkml changing the maintainership to myself.

Patches will still need to be applied through someone's tree, probably
David Miller's, since I don't have my own.

I think your series and Florian's patches are still in my inbox.  I'll try
to look at them today and provide feedback.

Regards,
Hartley
