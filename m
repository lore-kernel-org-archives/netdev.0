From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 23:21:15 -0700
Message-ID: <1284531675.24603.259.camel@localhost.localdomain>
References: <1284476719.13351.35.camel@localhost.localdomain>
	 <201009141721.13202.arnd@arndb.de> <20100914152231.GA13105@redhat.com>
	 <1284480025.13351.49.camel@localhost.localdomain>
	 <20100914162952.GB13560@redhat.com>
	 <1284483745.13351.71.camel@localhost.localdomain>
	 <20100914182707.GB15549@redhat.com>
	 <1284490143.13351.82.camel@localhost.localdomain>
	 <20100914190156.GA16037@redhat.com>
	 <1284492983.13351.95.camel@localhost.localdomain>
	 <20100915051241.GA25340@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100915051241.GA25340@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-15 at 07:12 +0200, Michael S. Tsirkin wrote:
> Yes, I agree this patch is useful for demo purposes:
> simple, and shows what kind of performance gains
> we can expect for TX. 

Any other issue you can see in this patch beside vhost descriptors
update?  Don't you think once I address vhost_add_used_and_signal update
issue, it is a simple and complete patch for macvtap TX zero copy?

Thanks
Shirley
