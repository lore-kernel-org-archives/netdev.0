From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with  "alive" pppoe interfaces
Date: Tue, 20 Oct 2009 03:08:57 +0300
Message-ID: <200910200308.57381.denys@visp.net.lb>
References: <200910190002.39937.denys@visp.net.lb> <20091019205740.GD5233@lenovo> <e6d1cecd0910191422t2905d9bbl3355fc50cf36ff90@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Michal Ostrowski <mostrows@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <e6d1cecd0910191422t2905d9bbl3355fc50cf36ff90@mail.gmail.com>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 October 2009 00:22:39 Michal Ostrowski wrote:
> I'm assuming that there was a race in us sending patches at nearly the same
> time I'm convinced now that the flush_lock can die, and the patch I sent
> out kills it.
o_O 

I am drowning in patches. Just let me know which one to test :-)
