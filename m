From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Fri, 8 Jun 2012 11:41:06 -0400
Message-ID: <20120608154106.GD5024@kvack.org>
References: <7ed49f446365ac625437702d92946add@visp.net.lb> <20120607205356.GA2491@electric-eye.fr.zoreil.com> <1339104606.6001.4.camel@edumazet-glaptop> <20120607223752.GA4475@electric-eye.fr.zoreil.com> <1339134438.6001.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339134438.6001.13.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2012 at 07:47:18AM +0200, Eric Dumazet wrote:
> I have no idea how many l2tp_eth devices are setup at once in typical
> conf.

Depends on the usage scenario.  L2TP is commonly used for terminating 
customer connections by wholesale ISPs.  In that kind of edge routing 
use-case, tens of thousands of interfaces are easily possible.

		-ben
-- 
"Thought is the essence of where you are now."
