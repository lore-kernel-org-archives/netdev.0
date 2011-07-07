From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V8 0/4 net-next] macvtap/vhost TX zero-copy support
Date: Thu, 07 Jul 2011 04:49:10 -0700 (PDT)
Message-ID: <20110707.044910.156889850897136407.davem@davemloft.net>
References: <1309990525.10209.12.camel@localhost.localdomain>
	<20110707.040840.809661052978541081.davem@davemloft.net>
	<20110707113715.GA32632@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110707113715.GA32632@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 7 Jul 2011 14:37:15 +0300

> Apply patches 1-3 for now?

Done, and I fixed the use-after-free in patch #2.

