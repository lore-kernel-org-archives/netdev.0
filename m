From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv7 1/3] tun: export underlying socket
Date: Wed, 04 Nov 2009 05:30:29 -0800 (PST)
Message-ID: <20091104.053029.166783766.davem@davemloft.net>
References: <cover.1257267892.git.mst@redhat.com>
	<20091103172400.GB5591@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
	linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com,
	gregory.haskins@gmail.com, rusty@rustcorp.com.au,
	s.hetze@linux-ag.com
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091103172400.GB5591@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 3 Nov 2009 19:24:00 +0200

> Assuming it's okay with davem, I think it makes sense to merge this
> patch through Rusty's tree because vhost is the first user of the new
> interface.  Posted here for completeness.

I'm fine with that, please add my:

Acked-by: David S. Miller <davem@davemloft.net>
