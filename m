From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix typos and whitespace.
Date: Wed, 23 Mar 2016 20:55:31 -0400 (EDT)
Message-ID: <20160323.205531.508870857957275663.davem@davemloft.net>
References: <20160323134530.18742.35082.stgit@bhelgaas-glaptop2.roam.corp.google.com>
	<20160323.142703.2259993852905081527.davem@davemloft.net>
	<CALx6S34KC2cGwvW0RPE_9CEABhrTOrbhkBYb5Eg3PpQ8rspsAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S34KC2cGwvW0RPE_9CEABhrTOrbhkBYb5Eg3PpQ8rspsAg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 23 Mar 2016 17:28:20 -0700

> On Wed, Mar 23, 2016 at 11:27 AM, David Miller <davem@davemloft.net> wrote:
>> From: Bjorn Helgaas <bhelgaas@google.com>
>> Date: Wed, 23 Mar 2016 08:45:30 -0500
>>
>>> Fix typos.  Capitalize CPU, NAPI, RCU consistently.  Align structure
>>> indentation.  No functional change intended; only comment and whitespace
>>> changes.
>>>
>>> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
>>
>> Does not apply to the current 'net' tree, please respin.
> 
> Why is this for net and not net-next?

Fixing comment typos is always appropriate, as they enhance
understanding of the code and make it easier to maintain.
