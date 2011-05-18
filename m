From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Wed, 18 May 2011 11:45:04 +0300
Message-ID: <20110518084504.GH7589@redhat.com>
References: <1305579414.3456.49.camel@localhost.localdomain>
 <20110516212401.GF18148@redhat.com>
 <1305606683.10756.3.camel@localhost.localdomain>
 <20110517055503.GA26989@redhat.com>
 <1305645734.10756.14.camel@localhost.localdomain>
 <20110517152840.GA2389@redhat.com>
 <1305646444.10756.16.camel@localhost.localdomain>
 <1305665419.10756.33.camel@localhost.localdomain>
 <20110517212827.GC7589@redhat.com>
 <1305695674.10756.93.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305695674.10756.93.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2011 at 10:14:34PM -0700, Shirley Ma wrote:
> Yes, fixed it already. I might change it to PAGE_SIZE for now since the
> small message sizes regression issue.

If that fixes it, let's do that for now.
-- 
MST
