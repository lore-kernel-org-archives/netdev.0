From: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Subject: RE: [PATCH net-next] change nfqueue failopen to apply also to receive
 message buffer in addition to queue size
Date: Wed, 23 Mar 2016 11:40:14 +0000
Message-ID: <aecaf341ed194fd991ed1709c3634dab@XCH-RTP-014.cisco.com>
References: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
 <20160321213532.GA1818@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"Florian Westphal (fw@strlen.de)" <fw@strlen.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160321213532.GA1818@salvia>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, March 21, 2016 11:36 PM, Pablo Neira Ayuso wrote:
> So isn't the more simple patch that I'm attaching achieving what you need?
Yes. I applied the patch and it works as expected. Indeed much more simple.

I intend to use this patch and would like it to eventually get into the formal kernel. Do you intend to pursue this into mainline kernel? 

