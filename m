From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v2a RESEND 2/2] of_mdio: Allow the DT to specify the phy
 ID and avoid autoprobing
Date: Wed, 19 Mar 2014 16:36:33 -0600
Message-ID: <20140319223633.GC1154@obsidianresearch.com>
References: <1394658311-17769-1-git-send-email-jgunthorpe@obsidianresearch.com>
 <1394658311-17769-2-git-send-email-jgunthorpe@obsidianresearch.com>
 <CAL_Jsq+qdbiwXErkZv1zZ9rphYY9NP6zHmmjw313tMvGeSTODg@mail.gmail.com>
 <20140319221404.GA1154@obsidianresearch.com>
 <532A262B.803@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robherring2@gmail.com>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <532A262B.803@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2014 at 02:20:11AM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 03/20/2014 01:14 AM, Jason Gunthorpe wrote:
> 
> >>    The preferred multi-line comment style is:
> 
> >>/*
> >>  * bla
> >>  * bla
> >>  */
> 
> >Sergei, the entire file use the 'net' multi-line commenting style, and
> >I have maintined that consistency with the new code.
> 
>    No, you haven't followed the networking style. It is:
> 
> /* bla
>  * bla
>  */
> 
> while your comment used:
> 
> /* bla
>  * bla */

Oh Ok - but the latter is the used by the majority of pre-existing
comments..

I thought the convention on stuff like this was to stick with the
existing style?

Do you think it is worth a v4? If so, which style is appropriate?
There is one other pre-existing comment that uses net.

Regards,
Jason
