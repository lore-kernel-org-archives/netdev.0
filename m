From: David Miller <davem@davemloft.net>
Subject: Re: [net 4/6] netfilter: Fix FSF address in file headers
Date: Fri, 06 Dec 2013 12:39:14 -0500 (EST)
Message-ID: <20131206.123914.797180241139683237.davem@davemloft.net>
References: <1386350024-25308-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1386350024-25308-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	netfilter@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu
To: jeffrey.t.kirsher@intel.com
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1386350024-25308-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  6 Dec 2013 09:13:42 -0800

> Several files refer to an old address for the Free Software Foundation
> in the file header comment.  Resolve by replacing the address with
> the URL <http://www.gnu.org/licenses/> so that we do not have to keep
> updating the header comments anytime the address changes.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
