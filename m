From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: Updated FarSync driver
Date: Sat, 27 Jul 2013 02:41:22 +0300
Message-ID: <20130726234122.GH5585@mwanda>
References: <20121009072047.GB19159@elgon.mountain>
 <E603DC592C92B54A89CEF6B0919A0B1CA86BBBD5E2@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Kevin Curtis <Kevin.Curtis@farsite.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CA86BBBD5E2@SOLO.hq.farsitecommunications.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 26, 2013 at 11:13:25AM +0100, Kevin Curtis wrote:
> Hi David,
>     I'd like to update the FarSync driver for our T-Series cards
> in the latest Linux Kernel and I would also like to add a new
> driver for our FarSync Flex USB device.
> 
> Should I direct the patch to you?
> 

Read Documentation/SubmittingPatches
Use ./scripts/get_maintainer.pl to find who needs to be CC'd.

If you want, you can send your first attempt to kernel-janitors
without CC'ing Dave and netdev and we will tell you which bits of
SubmittingPatches you have missed.

regards,
dan carpenter

