From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH v2 2/2] virtio_net: Defer skb allocation in receive path
Date: Wed, 13 Jan 2010 14:23:48 -0800
Message-ID: <1263421428.29594.5.camel@localhost.localdomain>
References: <1261122090.4148.24.camel@localhost.localdomain>
	 <1261122289.4148.27.camel@localhost.localdomain>
	 <20091224133749.GB2855@amit-x200.redhat.com>
	 <1262640344.18773.2.camel@localhost.localdomain>
	 <20100104211454.GB21488@redhat.com>
	 <1263236965.11949.1.camel@localhost.localdomain>
	 <1263416018.29594.1.camel@localhost.localdomain>
	 <20100113205750.GD21445@redhat.com>
	 <1263418421.29594.3.camel@localhost.localdomain>
	 <20100113213736.GF21445@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100113213736.GF21445@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-01-13 at 23:37 +0200, Michael S. Tsirkin wrote:
> Yes, separate patch is best.

The send side patch is done, I will submit it when this patch has been
reviewed. :)

thanks
Shirley

