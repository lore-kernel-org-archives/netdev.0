From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH 4/5] r8169: ethtool message level control
Date: Sat, 12 Mar 2005 15:12:28 +0000
Message-ID: <423306DC.40105@phekda.gotadsl.co.uk>
References: <20050309113402.05d25e49@dxpl.pdx.osdl.net> <4232DA4F.5050804@phekda.gotadsl.co.uk> <20050312143324.GA15154@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050312143324.GA15154@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Francois Romieu wrote:
[snip]
> I'll fix it and convert the remaining printk as well during the merge
> of your version with this one.

I think you should disregard my patch and just use Stephen's. His patch 
is what I was hoping to end up with, after fixing my patch. ;)

Likewise for my statistics patch - please use Stephen's, if you're happy 
with setting up the DMA mappings on each get_ethtool_stats call.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
