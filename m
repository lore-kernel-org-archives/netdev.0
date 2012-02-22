From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH] checkpatch: Add some --strict coding style checks
Date: Tue, 21 Feb 2012 17:58:55 -0800
Message-ID: <1329875935.5143.24.camel@joe2Laptop>
References: <20120221151435.GA19354@tuxdriver.com>
	 <20120221.144417.1445117001833888214.davem@davemloft.net>
	 <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
	 <20120221.154053.2103818562080068513.davem@davemloft.net>
	 <1329857959.5143.11.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A18429B3EE@ORSMSX102.amr.corp.intel.com>
	 <1329874581.5143.22.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A18429B8F2@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Whitcroft <apw@shadowen.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"andrei.emeltchenko.news@gmail.com"
	<andrei.emeltchenko.news@gmail.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18429B8F2@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-22 at 01:56 +0000, Allan, Bruce W wrote:
> > On Tue, 2012-02-21 at 22:09 +0000, Allan, Bruce W wrote:
> > > This appears to falsely complain about parenthesis alignment in
> > > conditional statements with multiple opening parentheses.
> > Can you try this one please?
[]
> It's better, but there are still instances of false hits AFAICT.

Do you have any examples?
The only one I noticed was spaces for alignment instead of tabs.
I think that's not a false hit myself.
