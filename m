From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv9] vhost: experimental tx zero-copy support
Date: Sun, 17 Jul 2011 12:53:14 -0700 (PDT)
Message-ID: <20110717.125314.2233794351034635919.davem@davemloft.net>
References: <20110717193540.GA29392@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110717193540.GA29392@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 17 Jul 2011 22:36:14 +0300

> The below is what I came up with. We add the feature enabled
> by default ...

s/enabled/disabled/  Well, at least you got it right in the
commit message where it counts :-)
