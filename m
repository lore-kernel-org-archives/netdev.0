From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.10-rc2] 3c59x: reload EEPROM values at rmmod for	needy
 cards
Date: Sun, 28 Nov 2004 14:06:59 -0500
Message-ID: <41AA21D3.5050205@pobox.com>
References: <20041117160122.A4824@tuxdriver.com>	 <20041117134425.62034944.akpm@osdl.org>	 <20041118012155.GA22765@tuxdriver.com> <1101663389.16787.46.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, Andrew Morton <akpm@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1101663389.16787.46.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> On Iau, 2004-11-18 at 01:21, John W. Linville wrote:
> 
>>On Wed, Nov 17, 2004 at 01:44:25PM -0800, Andrew Morton wrote:
>>
>>>This has been in -mm kernels since you first sent it out.  I'm intending to
>>>hold off until post-2.6.10 so we get a full kernel cycle for any problems
>>>to get shaken out.
>>
>>Cool...someone was asking for it in netdev-2.[46], and Jeff didn't
>>have it.  That is what provoked the resend.
> 
> 
> Merged into -ac since you essentially can't use 3c59x/3c90x with DHCP on
> some systems or get it back from suspend with several distributions.
> This IMHO should go into 2.6.10 because its a showstopper for many
> users. 

Poke Andrew to push it upstream, he's the 3c59x maintainer.

	Jeff
