From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Tue, 17 May 2011 14:01:52 -0700
Message-ID: <1305666112.10756.37.camel@localhost.localdomain>
References: <1305574484.3456.30.camel@localhost.localdomain>
	 <20110516204540.GD18148@redhat.com>
	 <1305579414.3456.49.camel@localhost.localdomain>
	 <20110516212401.GF18148@redhat.com>
	 <1305606683.10756.3.camel@localhost.localdomain>
	 <20110517055503.GA26989@redhat.com>
	 <1305645734.10756.14.camel@localhost.localdomain>
	 <20110517152840.GA2389@redhat.com>
	 <1305646444.10756.16.camel@localhost.localdomain>
	 <1305665419.10756.33.camel@localhost.localdomain>
	 <20110517205827.GB7589@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110517205827.GB7589@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-17 at 23:58 +0300, Michael S. Tsirkin wrote:
> On Tue, May 17, 2011 at 01:50:19PM -0700, Shirley Ma wrote:
> > Resubmit the patch with most update. This patch passed some
> > live-migration test against RHEL6.2. I will run more stress test w/i
> > live migration.
> 
> What changed from the last version?

Sorry, I forgot to mention: add clean up pending before set_vring.

Thanks
Shirley
