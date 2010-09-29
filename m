From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 29 Sep 2010 07:33:14 -0700
Message-ID: <1285770794.31343.10.camel@localhost.localdomain>
References: <20100914182707.GB15549@redhat.com>
	 <1284490143.13351.82.camel@localhost.localdomain>
	 <20100914190156.GA16037@redhat.com>
	 <1284492983.13351.95.camel@localhost.localdomain>
	 <20100915051241.GA25340@redhat.com>
	 <1284531675.24603.259.camel@localhost.localdomain>
	 <20100915101000.GB28016@redhat.com>
	 <1284562354.2573.12.camel@localhost.localdomain>
	 <1285730669.31343.7.camel@localhost.localdomain>
	 <20100929081645.GA21195@redhat.com>  <20100929082820.GC21195@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100929082820.GC21195@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-29 at 10:28 +0200, Michael S. Tsirkin wrote:
> I think you should try testing with guest to external communication,
> this will uncover some of these correctness issues for you.
> I think netperf also has some flag to check data, might
> be a good idea to use it for testing.

I always tested guest to remote host, remote host to guest. What other
external communication do you suggest here?

Thanks
Shirley

