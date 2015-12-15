From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix uninitialized variable issue
Date: Tue, 15 Dec 2015 15:15:22 -0800
Message-ID: <1450221322.8474.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151215184617.11620.23369.stgit@tstruk-mobl1>
	 <1450206129.8474.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5670973C.7030406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, freude@linux.vnet.ibm.com,
	viro@zeniv.linux.org.uk, linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5670973C.7030406@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-15 at 14:42 -0800, Tadeusz Struk wrote:

> It was added in this commit: 0345f93138b2 ("net: socket: add support for async operations")
> 

Thanks !
