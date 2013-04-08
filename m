From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Call nlmsg_parse() with correct header
 length
Date: Mon, 08 Apr 2013 17:12:54 -0400 (EDT)
Message-ID: <20130408.171254.1610343775047047438.davem@davemloft.net>
References: <e04bc546-fcf6-41d2-a585-5fddff388e06@mary.at.omicron.at>
	<CD31A507-C3E1-4499-9F06-2F83B3FBFE61@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.riesch@omicron.at, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org, jbenc@redhat.com, tytso@mit.edu,
	linux-kernel@vger.kernel.org
To: mark.d.rustad@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CD31A507-C3E1-4499-9F06-2F83B3FBFE61@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Date: Mon, 8 Apr 2013 18:13:36 +0000

> On Apr 8, 2013, at 8:45 AM, Michael Riesch <michael.riesch@omicron.at> wrote:
> 
>> 
>> Signed-off-by: Michael Riesch <michael.riesch@omicron.at>
 ...
> I found that fcoemon has also been triggering these messages for
> some time. I found the same problem and arrived at exactly the same
> solution. I would have already sent it, but it is still in
> validation. As far as I am concerned:
> 
> Acked-by: Mark Rustad <mark.d.rustad@intel.com>

Looks good to me too, applied and queued up for -stable, thanks!
