From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use __GFP_NORETRY for high order allocations
Date: Thu, 06 Feb 2014 13:00:39 -0800
Message-ID: <1391720439.10160.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391712162.10160.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391718270.15777.20.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	David Rientjes <rientjes@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391718270.15777.20.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-02-06 at 12:24 -0800, Joe Perches wrote:

> Perhaps add __GFP_THISNODE too ?

Why ?
