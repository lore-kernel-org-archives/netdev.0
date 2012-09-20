From: Ed Cashin <ecashin@coraid.com>
Subject: Re: [PATCH 1/2] aoe: mark AoE packets as requiring no checksumming
Date: Wed, 19 Sep 2012 20:40:40 -0500
Message-ID: <4DD17064-F075-48D0-8C3D-EFF6C043BA50@coraid.com>
References: <1348079358.4585@cat.he.net>
 <cover.1348088283.git.ecashin@coraid.com>
 <72368962c6414543ce7d2c3f1ab5f36154fdd710.1348088283.git.ecashin@coraid.com>
 <1348104303.4836.63.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348104303.4836.63.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sep 19, 2012, at 9:25 PM, Ben Hutchings wrote:

> Can be written as:
> 		skb_checksum_none_assert(skb);

Another good idea.  I'll resend.

-- 
  Ed Cashin
  ecashin@coraid.com
