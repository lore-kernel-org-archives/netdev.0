From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: Report link speed only when possible
Date: Fri, 13 Jun 2014 13:03:50 -0700 (PDT)
Message-ID: <20140613.130350.1729507484821351177.davem@davemloft.net>
References: <20140606085733.GJ2984@minipsycho.orion>
	<20140606.125447.1665616708152334692.davem@davemloft.net>
	<539AC237.40402@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mprivozn@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <539AC237.40402@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Privoznik <mprivozn@redhat.com>
Date: Fri, 13 Jun 2014 11:19:51 +0200

> So if I were developing brand new application I could say: I'm
> dropping all this workaround code and have it clean and require say
> 3.16 kernel at least.

Then your application wouldn't be usable on %99 of systems for a long
long time.

I don't think this is the right tradeoff at all.
