From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] change nfqueue failopen to apply also to
 receive message buffer in addition to queue size
Date: Wed, 23 Mar 2016 12:58:26 +0100
Message-ID: <20160323115826.GA19066@salvia>
References: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
 <20160321213532.GA1818@salvia>
 <aecaf341ed194fd991ed1709c3634dab@XCH-RTP-014.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"Florian Westphal (fw@strlen.de)" <fw@strlen.de>
To: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <aecaf341ed194fd991ed1709c3634dab@XCH-RTP-014.cisco.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2016 at 11:40:14AM +0000, Yigal Reiss (yreiss) wrote:
> On Monday, March 21, 2016 11:36 PM, Pablo Neira Ayuso wrote:
> > So isn't the more simple patch that I'm attaching achieving what you need?
>
> Yes. I applied the patch and it works as expected. Indeed much more
> simple.
> 
> I intend to use this patch and would like it to eventually get into
> the formal kernel. Do you intend to pursue this into mainline
> kernel?

Just made a formal submission of the patch.
