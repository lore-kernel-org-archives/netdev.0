From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: net: nfc: BUG and panic in accept() on 3.5-rc2
Date: Mon, 11 Jun 2012 16:41:34 +0200
Message-ID: <20120611144134.GX22557@sortiz-mobl>
References: <1339423241.4999.53.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, Dave Jones <davej@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339423241.4999.53.camel@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

On Mon, Jun 11, 2012 at 04:00:41PM +0200, Sasha Levin wrote:
> Hi all,
> 
> I've stumbled on the following while fuzzing with trinity inside a KVM tools guest, running on 3.5-rc2:
> 
Thanks for the report, it could be worth adding this one to
bugzilla.kernel.org.

What's trinity ?
Also, if this one is reproducible, would you mind sharing some details about
how we could reproduce it ?

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
