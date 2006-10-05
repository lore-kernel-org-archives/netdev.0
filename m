From: Pavel Roskin <proski@gnu.org>
Subject: Re: 2.6.18-mm2 - oops in cache_alloc_refill()
Date: Thu, 05 Oct 2006 18:37:53 -0400
Message-ID: <1160087873.2508.21.camel@dv>
References: <20060928014623.ccc9b885.akpm@osdl.org>
	 <200609290319.k8T3JOwS005455@turing-police.cc.vt.edu>
	 <20060928202931.dc324339.akpm@osdl.org>
	 <200609291519.k8TFJfvw004256@turing-police.cc.vt.edu>
	 <20060929124558.33ef6c75.akpm@osdl.org>
	 <200609300001.k8U01sPI004389@turing-police.cc.vt.edu>
	 <20060929182008.fee2a229.akpm@osdl.org>
	 <20061002175245.GA14744@bougret.hpl.hp.com>
	 <2006-10-03-17-58-31+trackit+sam@rfc1149.net>
	 <20061003163415.GA17252@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Samuel Tardieu <sam@rfc1149.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932401AbWJEWh6@vger.kernel.org>
To: jt@hpl.hp.com
In-Reply-To: <20061003163415.GA17252@bougret.hpl.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On Tue, 2006-10-03 at 09:34 -0700, Jean Tourrilhes wrote:
> 	I don't really want to overstep my authority there, my goal
> was to minimise the changes. Pavel will have to clean up my mess, so I
> don't want change things too much.

Sorry for a long delay.

I'm actually not very interested in the Wireless Extension interface of
the driver.  The less I touch that code, the better I feel.  I won't add
to the criticism for the latest changes; enough has been said.

Its fine with me that your are changing the orinoco driver to update
Wireless Extensions compatibility.

I'm trying to maintain a Subversion repository with the driver modified
to be compatible with a few latest kernels.  But it looks like it's an
uphill battle that I'm not going to win.

-- 
Regards,
Pavel Roskin
